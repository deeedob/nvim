local M = {}

local cmake = require("cmake-tools")
local perfanno = require("perfanno")

local is_darwin = vim.loop.os_uname().sysname == "Darwin"

local function profiler_cmd(target_path)
  if is_darwin then
    return { "samply", "record", "--save-only", "--output", "profile.json", target_path }
  else
    return { "perf", "record", "-g", "--output=perf.data", target_path }
  end
end

--- Converts the raw profiler output to a folded flamegraph at perf.log,
--- which is the filename perfanno.load_flamegraph() looks for via get_data_file().
local function convert_to_flamegraph(callback)
  local shell_cmd
  if is_darwin then
    shell_cmd = "samply export flamegraph profile.json > perf.log"
  else
    shell_cmd = "perf script | stackcollapse-perf.pl > perf.log"
  end

  vim.fn.jobstart({ "sh", "-c", shell_cmd }, {
    cwd = vim.fn.getcwd(),
    on_exit = function(_, code)
      if code == 0 then
        callback()
      else
        vim.notify("cmake_profile: flamegraph conversion failed (exit " .. code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

local function run_profiler(target_path)
  local cmd = profiler_cmd(target_path)
  vim.notify("cmake_profile: profiling " .. target_path)

  vim.fn.jobstart(cmd, {
    cwd = vim.fn.getcwd(),
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("cmake_profile: profiler exited with code " .. code, vim.log.levels.ERROR)
        return
      end

      convert_to_flamegraph(function()
        -- load_flamegraph is a coroutine.wrap'd function; call with no args,
        -- it finds perf.log itself via get_data_file("perf.log").
        perfanno.load_flamegraph()
        perfanno.annotate()
        vim.notify("cmake_profile: profiling loaded")
      end)
    end,
  })
end

function M.profile_current_target()
  local target = cmake.get_launch_target()

  if not target then
    vim.notify("cmake_profile: no CMake launch target selected", vim.log.levels.WARN)
    return
  end

  -- Build the target first, then exec the binary under the profiler.
  cmake.build({ target = target }, function(build_code)
    if build_code ~= 0 then
      vim.notify("cmake_profile: build failed", vim.log.levels.ERROR)
      return
    end

    -- Construct the path from cmake-tools' build directory + target name.
    -- Adjust if your project uses a subdirectory layout (e.g. bin/<target>).
    local build_dir = cmake.get_build_directory()
    if not build_dir then
      vim.notify("cmake_profile: could not determine build directory", vim.log.levels.ERROR)
      return
    end

    local target_path = build_dir .. "/" .. target
    run_profiler(target_path)
  end)
end

return M

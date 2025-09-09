return {
  "Civitasv/cmake-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    local local_cmake = "CMakeLists.txt"
    -- async determine a possible project dir
    vim.uv.fs_stat(local_cmake, function(_, stat)
      --  Check current dir for a CMakeLists.txt
      if stat then
        local file = io.open(local_cmake, "r")
        if file then
          local content = file:read "*all"
          file:close()
          if content:find "project%s*%(" then
            vim.schedule(function()
              require "ddob.cmake-tools"
            end)
          end
        end
      end
      -- CWD doesn't have a valid CMakeLists.txt. Search the project root
      local project_root = require("utils.functions").find_project_root()
      if project_root then
        local proj = vim.uv.fs_stat(project_root .. "/CMakeLists.txt")
        if proj then
          -- We expect that this CMakeLists.txt file in root is already valid
          vim.schedule(function()
            require("cmake-tools").select_cwd(proj)
          end)
        end
      end
    end)
    return true
  end,
  keys = {
    { "<leader>cg", ":CMakeGenerate<CR>", desc = "CMake Configure" },
    { "<leader>cb", ":CMakeBuild<CR>", desc = "CMake Build" },
    { "<leader>cr", ":CMakeRun<CR>", desc = "CMake Run" },
    { "<leader>cd", ":CMakeDebug<CR>", desc = "CMake Debug" },

    { "<leader>cG", ":CMakeGenerate!<CR>", desc = "CMake Force Configure" },
    { "<leader>cB", ":CMakeBuild!<CR>", desc = "CMake Force Build" },
    { "<leader>cR", ":CMakeQuickRun<CR>", desc = "CMake Quick Run" },
    { "<leader>cD", ":CMakeQuickDebug<CR>", desc = "CMake Quick Debug" },

    { "<leader>ck", ":CMakeStop<CR>", desc = "CMake Kill" },
    { "<leader>cc", ":CMakeClean<CR>", desc = "CMake Clean" },

    {
      "<leader>csr",
      ":CMakeSelectLaunchTarget<CR>",
      desc = "CMake Select Run Target",
    },
    {
      "<leader>csb",
      ":CMakeSelectBuildTarget<CR>",
      desc = "CMake Select Build Target",
    },
    {
      "<leader>cst",
      ":CMakeSelectBuildType<CR>",
      desc = "CMake Select Build Type",
    },
    { "<leader>csk", ":CMakeSelectKit<CR>", desc = "CMake Select Kit" },
    {
      "<leader>csf",
      ":CMakeShowTargetFiles<CR>",
      desc = "CMake Show Target's files",
    },
    { "<leader>css", ":CMakeSettings<CR>", desc = "CMake Project Settings" },
    {
      "<leader>csc",
      ":CMakeSelectConfigurePreset<CR>",
      desc = "CMake Configure Preset",
    },
  },
  config = function()
    vim.api.nvim_create_user_command("CMakeWipe", function()
      local build_dir = require("cmake-tools").get_build_directory()
      if build_dir then
        local cmd = "rm -rf " .. build_dir.filename
        print(cmd)
        vim.fn.system(cmd)
      end
      vim.cmd [[CMakeGenerate]]
    end, { desc = "Wipe build dir and start fresh" })

    vim.keymap.set(
      "n",
      "<leader>cw",
      ":CMakeWipe<cr>",
      { desc = "[w]ipe Build Dir", remap = true }
    )

    local nproc = tonumber(os.getenv "COMPILE_CORES")

    require("cmake-tools").setup {
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_use_preset = true,
      cmake_regenerate_on_save = false,
      cmake_generate_options = {
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
        "-DQT_QML_GENERATE_QMLLS_INI=1",
      },
      cmake_build_options = { "-j " .. tostring(nproc) },
      cmake_build_directory = "cmake-build/${variant:buildType}",
      cmake_soft_link_compile_commands = false,
      cmake_compile_commands_from_lsp = false,
      cmake_kits_path = vim.fn.stdpath "config" .. "/res/cmake-kits.json",
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
      cmake_executor = {
        name = "toggleterm",
        opts = {
          direction = "horizontal",
          close_on_exit = false,
          auto_scroll = false,
          scroll_on_error = true,
          auto_focus = false,
          focus_on_error = false,
          singleton = true,
        },
      },
      cmake_runner = {
        name = "toggleterm",
        opts = {
          direction = "horizontal",
          close_on_exit = false,
          auto_scroll = false,
          scroll_on_error = true,
          auto_focus = false,
          focus_on_error = true,
          singleton = true,
        },
      },
      cmake_notifications = {
        runner = { enabled = false },
        executor = { enabled = false },
      },
      cmake_virtual_text_support = false,
    }
  end,
}

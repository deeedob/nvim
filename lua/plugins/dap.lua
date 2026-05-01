local function pick_executable(opts)
  opts = opts or {}
  local fzf = require("fzf-lua")
  local cwd = opts.cwd or vim.fn.getcwd()

  return coroutine.create(function(coro)
    -- Use fd if available; otherwise fall back to find.
    local cmd = [[sh -c '
      if command -v fd >/dev/null 2>&1; then
        fd --hidden --no-ignore --type x --follow --exclude .git --exclude CMakeFiles .
      else
        find . \
          -path "./.git" -prune -o \
          -path "*/CMakeFiles/*" -prune -o \
          -type f -perm -111 -print 2>/dev/null | sed "s#^\./##"
      fi
    ']]

    if true then
      local cmake = require("cmake-tools")

      if cmake.is_cmake_project() then
        local build_dir = cmake.get_build_directory()
        if build_dir and build_dir ~= "" then
          cwd = build_dir.filename
        end
      end
    end

    fzf.fzf_exec(cmd, {
      cwd = cwd,
      prompt = opts.prompt or "Executable❯ ",
      actions = {
        ["default"] = function(selected)
          local choice = selected and selected[1] or nil
          if not choice or choice == "" then
            coroutine.resume(coro, nil)
            return
          end
          local abs = vim.fn.fnamemodify(cwd .. "/" .. choice:gsub("^%./", ""), ":p")
          coroutine.resume(coro, abs)
        end,
        ["esc"] = function()
          coroutine.resume(coro, nil)
        end,
      },
    })
  end)
end

local function get_qt6_paths()
  local config_path = vim.fn.stdpath("config")
  local base = config_path .. "/lua/debug/qt6renderer"
  return {
    gdb_package = base .. "/gdb",
    gdb_module = base .. "/gdb/qt6renderer",
    lldb = config_path .. "/lua/debug/qt6renderer/lldb",
  }
end

local function get_gdb_init_commands()
  local paths = get_qt6_paths()
  local qt6_init = paths.gdb_module .. "/__init__.py"
  if vim.fn.filereadable(qt6_init) ~= 1 then
    vim.notify("Qt6Renderer package not found at: " .. paths.gdb_module, vim.log.levels.ERROR)
    return { "set print pretty on" } -- Fallback to just pretty printing
  end
  -- TODO: doesn't work yet
  return {
    "python sys.path.append('/home/ddob/.config/nvim/lua/debug/qt6renderer/gdb')",
    "python import qt6renderer",
    "python gdb.pretty_printers.append(qt6renderer.qt6_lookup)",
    "set print pretty on",
  }
end

local function get_lldb_init_commands()
  local paths = get_qt6_paths()
  local register_script = paths.lldb .. "/register.py"

  -- Direct command script import with absolute path
  return {
    ("command script import '%s'"):format(register_script),
    "script print('Qt6Renderer pretty printers loaded for LLDB')",
    [[settings set target.process.thread.step-avoid-regexp "std::|__gnu_cxx|QGrpc|QtPrivate"]],

    "process handle -p true -s false -n false SIGSEGV",
    "process handle -p true -s false -n false SIGBUS",
    "process handle -p true -s false -n false SIGILL",
    "process handle -p true -s false -n false SIGFPE",
    "process handle -p true -s false -n false SIGUSR1",
    "process handle -p true -s false -n false SIGUSR2",

    "settings set target.process.stop-on-sharedlibrary-events false",
    "settings set target.process.stop-on-exec false",
  }
end

local function inherit_env()
  local env = {}
  for k, v in pairs(vim.fn.environ()) do
    env[k] = v
  end
  return env
end

local function create_configs(adapter_name, overrides)
  overrides = overrides or {}
  local base = {
    launch = {
      name = ("%s: Launch"):format(adapter_name),
      type = adapter_name,
      request = "launch",
      cwd = "${workspaceFolder}",
      program = function()
        return pick_executable({
          prompt = ("Path to executable (%s)❯ "):format(adapter_name),
        })
      end,
      args = {},
      stopOnEntry = false,
    },
    attach = {
      name = ("%s: Attach"):format(adapter_name),
      type = adapter_name,
      request = "attach",
      pid = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      args = {},
      stopOnEntry = true, -- default for cppdbg, others override
    },
  }

  for _, mode in ipairs({ "launch", "attach" }) do
    if overrides[mode] then
      for k, v in pairs(overrides[mode]) do
        base[mode][k] = v
      end
    end
  end

  if overrides.common then
    for _, mode in ipairs({ "launch", "attach" }) do
      for k, v in pairs(overrides.common) do
        -- Don't override if already set by mode-specific override
        if base[mode][k] == nil then
          base[mode][k] = v
        end
      end
    end
  end

  return { base.launch, base.attach }
end

local function setup_cpp_configs()
  local dap = require("dap")
  local configs = {}

  -- 1. System lldb-dap (highest priority)
  local lldb_dap_cmd
  for _, cmd in ipairs({ "/usr/bin/lldb-dap", "/usr/bin/lldb-vscode" }) do
    if vim.fn.executable(cmd) == 1 then
      lldb_dap_cmd = cmd
      break
    end
  end

  if lldb_dap_cmd then
    dap.adapters.lldb_dap = {
      type = "executable",
      command = lldb_dap_cmd,
      name = "lldb_dap",
    }

    vim.list_extend(
      configs,
      create_configs("lldb_dap", {
        attach = { stopOnEntry = false },
        launch = { stopOnEntry = false },
        common = {
          initCommands = get_lldb_init_commands(),
          env = inherit_env,
          enableAutoVariableSummaries = true,
          enableSyntheticChildDebugging = true,
          exceptionBreakpoints = {},
        },
      })
    )
  else
    vim.notify("lldb-dap/lldb-vscode not found in /usr/bin", vim.log.levels.WARN)
  end

  if vim.fn.executable("gdb") == 1 then
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    vim.list_extend(
      configs,
      create_configs("gdb", {
        attach = { stopOnEntry = true },
        common = {
          setupCommands = get_gdb_init_commands(),
        },
      })
    )
  end

  return configs
end

return {
  {
    "igorlfs/nvim-dap-view",
    opts = {
      winbar = {
        sections = {
          "scopes",
          "console",
          "threads",
          "breakpoints",
          "disassembly",
          "exceptions",
          "repl",
          "watches",
        },
        default_section = "scopes",
      },
    },
  },
  {
    url = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
    dependencies = "igorlfs/nvim-dap-view",
    config = true,
  },
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      "igorlfs/nvim-dap-view",
      "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
      {
        "jay-babu/mason-nvim-dap.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        dependencies = { "mason.nvim" },
      },
      "theHamsta/nvim-dap-virtual-text",
      { "jbyuki/one-small-step-for-vimkind", ft = "lua" },
    },
    keys = {
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Breakpoint Condition",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<leader>da",
      function()
        -- Prompt the user for program arguments before continuing/launching
        local dap = require("dap")
        vim.ui.input({ prompt = "Program arguments: " }, function(input)
          if input == nil then
            return
          end -- user cancelled
          -- Split the input string into an argv-style table
          local args = vim.split(input, "%s+", { trimempty = true })
          -- Store args on the active config so they are re-used by run_last
          local session = dap.session()
          if session then
            session.config.args = args
            dap.continue()
          else
            -- No active session: inject args into the first matching config
            dap.continue({
              before = function(config)
                config.args = args
                return config
              end,
            })
          end
        end)
      end,
      desc = "Run with args",
    },
    {
      "<leader>dC",
      function()
        require("dap").run_to_cursor()
      end,
      desc = "Run to Cursor",
    },
    {
      "<leader>dg",
      function()
        require("dap").goto_()
      end,
      desc = "Go to line (no execute)",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
    {
      "<leader>dj",
      function()
        require("dap").down()
      end,
      desc = "Down",
    },
    {
      "<leader>dk",
      function()
        require("dap").up()
      end,
      desc = "Up",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run Last",
    },
    {
      "<leader>do",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<F9>",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<leader>dp",
      function()
        require("dap").pause()
      end,
      desc = "Pause",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Toggle REPL",
    },
    {
      "<leader>ds",
      function()
        require("dap").session()
      end,
      desc = "Session",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },
    {
      "<leader>dw",
      function()
        require("dap.ui.widgets").hover()
      end,
      desc = "Widgets",
    },
    {
      "<leader>du",
      function()
        require("dap-view").toggle()
      end,
      desc = "Dap UI",
    },
    {
      "<leader>de",
      function()
        -- require("dapui").eval()
      end,
      desc = "Eval",
      mode = { "n", "v" },
    },
  },
  config = function()
    local dap = require("dap")
    require("nvim-dap-virtual-text").setup({})

    dap.listeners.before.attach.dapui_config = function()
      require("dap-view").open()
    end
    dap.listeners.before.launch.dapui_config = function()
      require("dap-view").open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      require("dap-view").close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      require("dap-view").close()
    end

    local keymap_restore = {}
    dap.listeners.after["event_initialized"]["me"] = function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local keymaps = vim.api.nvim_buf_get_keymap(buf, "n")
        for _, keymap in ipairs(keymaps) do
          if keymap.lhs == "K" then
            table.insert(keymap_restore, keymap)
            vim.api.nvim_buf_del_keymap(buf, "n", "K")
          end
        end
      end
      vim.keymap.set("n", "K", function()
        require("dap.ui.widgets").hover()
      end, { silent = true })
      vim.api.nvim_create_autocmd("WinLeave", {
        group = vim.api.nvim_create_augroup("ddob/dap-hover", { clear = true }),
        pattern = "dap-hover*",
        callback = function(event)
          pcall(vim.api.nvim_buf_delete, event.buf, {})
        end,
      })
    end
    dap.listeners.after["event_terminated"]["me"] = function()
      for _, keymap in ipairs(keymap_restore) do
        local rhs = keymap.callback or keymap.rhs
        vim.keymap.set(keymap.mode, keymap.lhs, rhs, {
          buffer = keymap.buffer,
          silent = keymap.silent == 1,
        })
      end
      keymap_restore = {}
    end

    local icons = {
      dap = {
        Stopped = { "󰁕 ", "DiagnosticWarn" },
        Breakpoint = { " ", "DiagnosticError" },
        BreakpointRejected = { " ", "DiagnosticError" },
        BreakpointCondition = { " ", "DiagnosticWarn" },
        LogPoint = ".>",
      },
    }
    for name, sign in pairs(icons.dap) do
      sign = type(sign) == "table" and sign or { sign }
      vim.fn.sign_define("Dap" .. name, {
        text = sign[1],
        texthl = sign[2] or "DapIconGutter",
        linehl = "",
        numhl = "",
      })
    end

    local system_cpp_configs = setup_cpp_configs()

    -- Initialize config tables
    for _, lang in ipairs({ "cpp", "c", "rust" }) do
      dap.configurations[lang] = dap.configurations[lang] or {}
      -- Prepend system configs (they take priority)
      vim.list_extend(dap.configurations[lang], system_cpp_configs)
    end

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,

        cppdbg = function(config)
          config.configurations = create_configs("cppdbg", {
            attach = {
              stoponentry = true,
              setupcommands = {
                {
                  text = "-enable-pretty-printing",
                  description = "enable pretty printing",
                  ignorefailures = false,
                },
              },
            },
            launch = {
              setupcommands = {
                {
                  text = "-enable-pretty-printing",
                  description = "enable pretty printing",
                  ignorefailures = false,
                },
              },
            },
          })
          require("mason-nvim-dap").default_setup(config)
        end,

        codelldb = function(config)
          config.configurations = create_configs("codelldb", {
            attach = { stopOnEntry = false },
            launch = { stopOnEntry = false },
            common = {
              initCommands = get_lldb_init_commands(),
              env = inherit_env,
            },
          })
          require("mason-nvim-dap").default_setup(config)
        end,
      },
      ensure_installed = {
        "codelldb",
        "cppdbg",
        "bash-debug-adapter",
      },
    })

    dap.adapters.nlua = function(callback, config)
      callback({
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or 8086,
      })
    end
    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
        port = 8086,
      },
    }
  end,
  },
}

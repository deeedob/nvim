local function pick_executable(opts)
  opts = opts or {}
  local fzf = require "fzf-lua"
  local cwd = opts.cwd or vim.fn.getcwd()

  return coroutine.create(function(coro)
    -- Use fd if available; otherwise fall back to find.
    local cmd = [[sh -c '
      if command -v fd >/dev/null 2>&1; then
        fd --hidden --no-ignore --type x --follow --exclude .git .
      else
        find . -type f -perm -111 -print 2>/dev/null | sed "s#^\./##"
      fi
    ']]

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
          -- Normalize ./path -> /abs/path
          local abs =
            vim.fn.fnamemodify(cwd .. "/" .. choice:gsub("^%./", ""), ":p")
          coroutine.resume(coro, abs)
        end,
        ["esc"] = function()
          coroutine.resume(coro, nil)
        end,
      },
    })
  end)
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "nvim-neotest/nvim-nio",
      },
    },
    {
      "jay-babu/mason-nvim-dap.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      dependencies = {
        "mason.nvim",
      },
    },
    "theHamsta/nvim-dap-virtual-text",
    {
      "jbyuki/one-small-step-for-vimkind",
      ft = "lua",
    },
  },
  keys = {
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
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
        require("dap").continue { before = get_args }
      end,
      desc = "Run with Args",
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
        require("dapui").toggle {}
      end,
      desc = "Dap UI",
    },
    {
      "<leader>de",
      function()
        require("dapui").eval()
      end,
      desc = "Eval",
      mode = { "n", "v" },
    },
  },
  config = function()
    -- require("dapui").setup {}
    require("dapui").setup {
      layouts = {
        -- 4 boxes on the left
        {
          position = "left",
          size = 50,
          elements = {
            { id = "watches", size = 0.00 },
            { id = "breakpoints", size = 0.3 },
            { id = "console", size = 0.5 },
            { id = "repl", size = 0.25 },
          },
        },

        {
          position = "bottom",
          size = 14,
          elements = {
            { id = "scopes", size = 0.7 },
            { id = "stacks", size = 0.3 },
          },
        },
      },
    }
    require("nvim-dap-virtual-text").setup {}

    local dap = require "dap"
    local dapui = require "dapui"

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Remove all normal keymap 'K' and set it to dap hover.
    -- Restore it when we're finished.
    local keymap_restore = {}
    dap.listeners.after["event_initialized"]["me"] = function()
      for _, buf in pairs(vim.api.nvim_list_bufs()) do
        local keymaps = vim.api.nvim_buf_get_keymap(buf, "n")
        for _, keymap in pairs(keymaps) do
          if keymap.lhs == "K" then
            table.insert(keymap_restore, keymap)
            vim.api.nvim_buf_del_keymap(buf, "n", "K")
          end
        end
      end

      vim.keymap.set("n", "K", function()
        require("dap.ui.widgets").hover()
      end, { silent = true })

      -- Auto close dap-hover buffer on BufLeave
      vim.api.nvim_create_autocmd("WinLeave", {
        group = vim.api.nvim_create_augroup("config", { clear = false }),
        pattern = "dap-hover*",
        callback = function(event)
          vim.api.nvim_buf_delete(event.buf, {})
        end,
      })
    end
    dap.listeners.after["event_terminated"]["me"] = function()
      for _, keymap in pairs(keymap_restore) do
        local rhs = keymap.callback ~= nil and keymap.callback or keymap.rhs
        vim.keymap.set(
          keymap.mode,
          keymap.lhs,
          rhs,
          { buffer = keymap.buffer, silent = keymap.silent == 1 }
        )
      end
      keymap_restore = {}
    end

    local sc = vim.api.nvim_get_hl(0, { name = "SignColumn", create = false })
    local ap = vim.api.nvim_get_hl(0, { name = "PreProc", create = false })
    vim.api.nvim_set_hl(
      0,
      "DapStoppedLine",
      { default = true, link = "Visual" }
    )
    vim.api.nvim_set_hl(0, "DapIconGutter", { fg = ap.fg, bg = sc.bg })
    local icons = {
      dap = {
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = { " " },
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
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

    require("mason-nvim-dap").setup {
      automatic_installation = true,
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
        cppdbg = function(config)
          config.configurations = {
            {
              name = "gdb: attach",
              type = "cppdbg",
              request = "attach",
              cwd = "${workspaceFolder}",
              -- processid = require('dap.utils').pick_process,
              stoponentry = true,
              setupcommands = {
                {
                  text = "-enable-pretty-printing",
                  description = "enable pretty printing",
                  ignorefailures = false,
                },
              },
            },
            {
              name = "gdb: launch",
              type = "cppdbg",
              request = "launch",
              cwd = "${workspaceFolder}",
              program = function()
                return pick_executable {
                  prompt = "Path to executable (cppdbg)❯ ",
                }
              end,
              setupcommands = {
                {
                  text = "-enable-pretty-printing",
                  description = "enable pretty printing",
                  ignorefailures = false,
                },
              },
            },
          }
          require("mason-nvim-dap").default_setup(config)
        end,
        -- https://github.com/vadimcn/codelldb/blob/master/MANUAL.md
        codelldb = function(config)
          local initCmd = function()
            local commands = {}

            local sources =
              { vim.env.HOME .. "/.lldbinit", vim.fn.getcwd() .. "/.lldbinit" }
            for _, source in ipairs(sources) do
              local f = io.open(source, "r")
              if f then
                table.insert(commands, "command source " .. source)
                f:close()
              end
            end
            table.insert(
              commands,
              [[settings set frame-format "${frame.index}: ${frame.pc} ${function.name-with-args} @ ${line.file.basename}:${line.number}\n"]]
            )
            table.insert(
              commands,
              [[settings set target.process.thread.step-avoid-regexp "std::|__gnu_cxx|QGrpc|QtPrivate"]]
            )
            return commands
          end
          config.configurations = {
            {
              name = "LLDB: Attach",
              type = "codelldb",
              request = "attach",
              pid = require("dap.utils").pick_process,
              args = {},
              stopOnEntry = false,
              initCommands = initCmd,
              env = function()
                local variables = {}
                for k, v in pairs(vim.fn.environ()) do
                  table.insert(variables, string.format("%s=%s", k, v))
                end
                return variables
              end,
            },
            {
              name = "LLDB: Launch",
              type = "codelldb",
              request = "launch",
              cwd = "${workspaceFolder}",
              initCommands = initCmd,

              program = function()
                return pick_executable {
                  prompt = "Path to executable (codelldb)❯ ",
                }
              end,
            },
          }
          require("mason-nvim-dap").default_setup(config)
        end,
        -- TODO: Doesn't work?
        -- lua = function(config)
        --   config.configurations = {
        --     {
        --       name = "Attach to running Neovim instance",
        --       type = "nlua",
        --       request = "attach",
        --     },
        --   }
        --   config.adapters = {
        --     type = "server",
        --     host = config.host or "127.0.0.1",
        --     port = config.port or 8086,
        --   }
        --   require("mason-nvim-dap").default_setup(config)
        -- end,
      },
      ensure_installed = {
        "codelldb",
        "cppdbg",
        "bash-debug-adapter",
      },
    }

    local lldb_dap_cmd = "/usr/bin/lldb-dap"
    if vim.fn.executable(lldb_dap_cmd) ~= 1 then
      lldb_dap_cmd = "/usr/bin/lldb-vscode"
      -- TODO: DON"T add then!
    end

    dap.adapters.lldb_dap = {
      type = "executable",
      command = lldb_dap_cmd,
      name = "lldb_dap",
    }

    local lldb_dap_init_cmd = function()
      local commands = {}

      local sources =
        { vim.env.HOME .. "/.lldbinit", vim.fn.getcwd() .. "/.lldbinit" }
      for _, source in ipairs(sources) do
        local f = io.open(source, "r")
        if f then
          table.insert(commands, "command source " .. source)
          f:close()
        end
      end
      table.insert(
        commands,
        [[settings set frame-format "${frame.index}: ${frame.pc} ${function.name-with-args} @ ${line.file.basename}:${line.number}\n"]]
      )
      table.insert(
        commands,
        [[settings set target.process.thread.step-avoid-regexp "std::|__gnu_cxx|QGrpc|QtPrivate"]]
      )
    end

    local inherit_env = function()
      local variables = {}
      for k, v in pairs(vim.fn.environ()) do
        table.insert(variables, string.format("%s=%s", k, v))
      end
      return variables
    end

    local lldb_dap_configs = {
      {
        name = "LLDB-DAP: Launch",
        type = "lldb_dap",
        request = "launch",
        cwd = "${workspaceFolder}",
        program = function()
          return pick_executable { prompt = "Path to executable (lldb-dap)❯ " }
        end,
        args = {},
        stopOnEntry = false,

        initCommands = lldb_dap_init_cmd,
        env = inherit_env,

        enableAutoVariableSummaries = true,
        enableSyntheticChildDebugging = true,
      },
      {
        name = "LLDB-DAP: Attach",
        type = "lldb_dap",
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        args = {},
        stopOnEntry = false,

        initCommands = lldb_dap_init_cmd,
        env = inherit_env,

        enableAutoVariableSummaries = true,
        enableSyntheticChildDebugging = true,
      },
    }

    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
        port = 8086,
      },
    }

    dap.adapters.nlua = function(callback, config)
      callback {
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or 8086,
      }
    end
    dap.configurations.cpp = dap.configurations.cpp or {}
    dap.configurations.c = dap.configurations.c or {}
    dap.configurations.rust = dap.configurations.rust or {}

    vim.list_extend(dap.configurations.cpp, lldb_dap_configs)
    vim.list_extend(dap.configurations.c, lldb_dap_configs)
    vim.list_extend(dap.configurations.rust, lldb_dap_configs)
  end,
}

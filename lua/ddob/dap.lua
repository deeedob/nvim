require("dapui").setup {
  layouts = {
    {
      elements = {
        {
          id = "scopes",
          size = 0.45,
        },
        {
          id = "stacks",
          size = 0.45,
        },
        {
          id = "breakpoints",
          size = 0.1,
        },
      },
      position = "left",
      size = 35,
    },
    {
      elements = {
        {
          id = "console",
          size = 1.0,
        },
      },
      position = "bottom",
      size = 10,
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
vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
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
      local pickers = require "telescope.pickers"
      local finders = require "telescope.finders"
      local conf = require("telescope.config").values
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"
      config.configurations = {
        {
          name = "gdb: attach",
          type = "cppdbg",
          request = "attach",
          cwd = "${workspacefolder}",
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
          cwd = "${workspacefolder}",
          program = function()
            return coroutine.create(function(coro)
              local opts = {}
              pickers
                .new(opts, {
                  prompt_title = "path to executable",
                  finder = finders.new_oneshot_job(
                    { "fd", "--hidden", "--no-ignore", "--type", "x" },
                    {}
                  ),
                  sorter = conf.generic_sorter(opts),
                  attach_mappings = function(buffer_number)
                    actions.select_default:replace(function()
                      actions.close(buffer_number)
                      coroutine.resume(
                        coro,
                        action_state.get_selected_entry()[1]
                      )
                    end)
                    return true
                  end,
                })
                :find()
            end)
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
      local pickers = require "telescope.pickers"
      local finders = require "telescope.finders"
      local conf = require("telescope.config").values
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"

      local initCmd = function()
        local commands = {}
        local sources =
          { vim.env.HOME .. "/.lldbinit", vim.fn.getcwd() .. "/.lldbinit" }
        for idx, source in ipairs(sources) do
          local file = io.open(source, "r")
          if file then
            local command = "command source " .. source
            table.insert(commands, command)
            file:close()
          end
        end
        print("cmd ", commands)
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
            return coroutine.create(function(coro)
              local opts = {}
              pickers
                .new(opts, {
                  prompt_title = "Path to executable",
                  finder = finders.new_oneshot_job(
                    { "fd", "--hidden", "--no-ignore", "--type", "x" },
                    {}
                  ),
                  sorter = conf.generic_sorter(opts),
                  attach_mappings = function(buffer_number)
                    actions.select_default:replace(function()
                      actions.close(buffer_number)
                      coroutine.resume(
                        coro,
                        action_state.get_selected_entry()[1]
                      )
                    end)
                    return true
                  end,
                })
                :find()
            end)
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

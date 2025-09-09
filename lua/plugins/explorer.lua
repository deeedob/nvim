local plug = require "utils.plugin"

return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Explorer",
      },

      {
        "<leader>-",
        function()
          require("oil").open_float()
        end,
        desc = "Explorer Float",
      },

      {
        "<leader>_",
        function()
          if not plug.loaded "cmake-tools" then
            return
          end
          local build_dir =
            require("cmake-tools").get_build_directory().filename
          require("oil").open(build_dir)
        end,
        desc = "Explore Build",
      },
    },

    opts = {
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<A-v>"] = { "actions.select", opts = { vertical = true } },
        ["<A-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<A-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-r>"] = "actions.refresh",
        ["-"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      view_options = {
        show_hidden = true,
      },
      use_default_keymaps = false,
    },

    init = function(p)
      if not plug.loaded "oil" then
        vim.api.nvim_create_autocmd("BufNew", {
          callback = function()
            if vim.fn.isdirectory(vim.fn.expand "<afile>") == 1 then
              require("lazy").load { plugins = { "oil.nvim" } }
              -- Once oil is loaded, we can delete this autocmd
              return true
            end
          end,
        })
      end
    end,
  },
}

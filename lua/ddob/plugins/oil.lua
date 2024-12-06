return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup {
        columns = { "icon" },
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
          ["<C-h>"] = "actions.select_split",
          show_hidden = true,
        },
        use_default_keymaps = false,
      }

      -- Open parent directory in current window
      vim.keymap.set(
        "n",
        "-",
        "<CMD>Oil<CR>",
        { desc = "Open parent directory" }
      )

      -- Open parent directory in floating window
      vim.keymap.set("n", "<leader>-", require("oil").toggle_float)
      vim.keymap.set("n", "<leader>_", function()
        local cmake = nil
        if package.loaded["cmake-tools"] then
          cmake = require "cmake-tools"
        end
        if cmake == nil then
          return
        end
        require("oil").open(cmake.get_build_directory().filename)
      end)
    end,
  },
}

return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    keys = {
      {
        "<leader>ugb",
        ":Gitsigns toggle_current_line_blame<cr>",
        "[G]it [B]lame Word",
      },
      { "<leader>ugh", ":Gitsigns toggle_linehl<cr>", "[G]it [L]ine Hl" },
      { "<leader>ugl", ":Gitsigns toggle_word_diff<cr>", "[G]it [W]ord Diff" },
      {
        "]g",
        function()
          return require("gitsigns").next_hunk()
        end,
        desc = "Next hunk",
      },
      {
        "[g",
        function()
          return require("gitsigns").prev_hunk()
        end,
        desc = "Previous hunk",
      },
      {
        "<leader>gl",
        function()
          return require("gitsigns").blame_line()
        end,
        desc = "blame [l]ine",
      },
      {
        "<leader>gp",
        function()
          return require("gitsigns").preview_hunk()
        end,
        desc = "[p]review hunk",
      },
      {
        "<leader>gr",
        function()
          return require("gitsigns").reset_hunk()
        end,
        mode = { "n", "v" },
        desc = "Reset the hunk",
      },
      {
        "<leader>gR",
        function()
          return require("gitsigns").reset_buffer()
        end,
        desc = "[R]eset buffer",
      },
      {
        "<leader>gs",
        function()
          return require("gitsigns").stage_hunk()
        end,
        mode = { "n", "v" },
        desc = "[s]tage hunk",
      },
      {
        "<leader>gS",
        function()
          return require("gitsigns").stage_buffer()
        end,
        desc = "[S]tage buffer",
      },
      {
        "<leader>gu",
        function()
          return require("gitsigns").undo_stage_hunk()
        end,
        desc = "[u]nstage the hunk",
      },
      {
        "<leader>gd",
        function()
          return require("gitsigns").diffthis()
        end,
        desc = "[d]iff",
      },
    },
    opts = {
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d>",
      max_file_length = 40000,
      attach_to_untracked = true,
    },
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gG", ":LazyGit<cr>", desc = "LazyGit" },
      {
        "<leader>gF",
        ":LazyGitFilterCurrentFile<cr>",
        desc = "LazyGit Current",
      },
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = "G",
    keys = {
      { "<leader>gf", ":vertical G<cr>", desc = "Fugitive" },
    },
  },

  -- TODO: needed?
  {
    "sindrets/diffview.nvim",
    enabled = false,
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
  },

}

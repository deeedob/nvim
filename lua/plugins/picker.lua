return {

  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false, -- plugins is self-lazy
    keys = {
      {
        "<leader>ff",
        function()
          require("fff").find_files()
        end,
        desc = "FFFind files",
      },
    },
    opts = {
      debug = {
        enabled = true, -- we expect your collaboration at least during the beta
        show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    cmd = "Telescope",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",

      {
        "nvim-telescope/telescope-fzf-native.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        build = "make",
      },

      {
        "nvim-telescope/telescope-ui-select.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
      },

      {
        "aaronhallaert/advanced-git-search.nvim",
        cmd = { "AdvancedGitSearch" },
      },
    },
    config = function()
      local data = assert(vim.fn.stdpath "data") --[[@as string]]

      require("telescope").setup {
        defaults = {
          initial_mode = "insert",
          file_ignore_patterns = {
            ".git/",
            "%.svg",
            "%.png",
            "%.jpeg",
            "%.jpg",
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
        },
        extensions = {
          wrap_results = true,
          undo = { use_delta = true },
          fzf = {
            fuzzy = true, -- false will only do exact matching
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {},
          },
          advanced_git_search = {
            -- See Config
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      }

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "advanced_git_search")

      local builtin = require "telescope.builtin"
      -- Lsp handlers
      vim.lsp.handlers["callHierarchy/incomingCalls"] =
        vim.lsp.with(builtin.lsp_incoming_calls, {
          trim_text = true,
        })

      vim.lsp.handlers["callHierarchy/outgoingCalls"] =
        vim.lsp.with(builtin.lsp_outgoing_calls, {
          trim_text = true,
        })

      -- Keymaps
      vim.keymap.set("n", "<leader>lv", function()
        builtin.lsp_definitions { jump_type = "vsplit" }
      end, { desc = "[D]efinition Vsplit", buffer = 0 })

      vim.keymap.set("n", "<leader>lh", function()
        require("telescope.builtin").lsp_definitions { jump_type = "split" }
      end, { desc = "[D]efinition HSplit", buffer = 0 })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find {
          require("telescope.themes").get_dropdown {
            winblend = 10,
            previewer = false,
          },
        }
      end, { desc = "current buffer fuzzy" })

      vim.keymap.set(
        "n",
        "<leader>fw",
        builtin.live_grep,
        { desc = "[w]ords (root)" }
      )

      vim.keymap.set("n", "<leader>fW", function()
        builtin.live_grep {
          cwd = require("telescope.utils").buffer_dir(),
        }
      end, { desc = "[W]ords (current)" })

      vim.keymap.set("n", "<leader>ft", function()
        builtin.live_grep {
          type_filter = vim.bo.filetype,
        }
      end, { desc = "words by f[t] (current)" })

      vim.keymap.set("n", "<leader>fT", function()
        builtin.live_grep {
          type_filter = vim.bo.filetype,
          search_dirs = { "/" },
          disable_coordinates = true,
        }
      end, { desc = "words by F[T] (global)" })

      -- vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "files (root)" })

      -- vim.keymap.set("n", "<leader>fF", function()
      --   builtin.find_files {
      --     cwd = require("telescope.utils").buffer_dir(),
      --   }
      -- end, { desc = "[F]iles (current)" })

      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[b]uffers" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[r]esume" })

      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[h]elp" })
      vim.keymap.set("n", "<leader>fH", function()
        return builtin.highlights {}
      end, { desc = "[H]ighlights" })

      vim.keymap.set("n", "<leader>fm", builtin.man_pages, { desc = "[m]an" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[k]eymaps" })

      vim.keymap.set("n", "<leader>fc", function()
        return builtin.find_files { cwd = vim.fn.stdpath "config" }
      end, { desc = "[c]onfig (user)" })
      vim.keymap.set("n", "<leader>fC", function()
        return builtin.find_files {
          cwd = vim.fs.joinpath(data, "lazy"),
        }
      end, { desc = "[c]onfig (lazy)" })

      vim.keymap.set("n", "<leader>fd", function()
        return builtin.diagnostics { bufnr = 0 }
      end, { desc = "[d]iagnostic (file)" })
      vim.keymap.set("n", "<leader>fD", function()
        return builtin.diagnostics {}
      end, { desc = "[d]iagnostic (project)" })

      -- Git bindings

      vim.keymap.set("n", "<leader>gc", function()
        return builtin.git_commits()
      end, { desc = "find [c]ommits" })

      vim.keymap.set("n", "<leader>gC", function()
        return builtin.git_bcommits()
      end, { desc = "find [C]ommits (current)" })

      vim.keymap.set("v", "<leader>gc", function()
        local b, e = require("utils.buffer").get_visual_pos()
        return builtin.git_bcommits_range {
          from = b[1],
          to = e[1],
        }
      end, { desc = "find [c]ommits (range)" })

      vim.keymap.set({ "n", "v" }, "<leader>gb", function()
        return require("utils.git").branches_for_code()
      end, { desc = "find code in [b]ranch" })

      -- vim.keymap.set("n", "<leader>gb", function()
      --   return builtin.git_branches()
      -- end, { desc = "find [b]ranches" })

      vim.keymap.set("n", "<leader>gB", function()
        return builtin.git_branches {
          show_remote_tracking_branches = false,
        }
      end, { desc = "find [B]ranches (local)" })
    end,
  },
}

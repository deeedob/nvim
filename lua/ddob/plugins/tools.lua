return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 500
        end,
        config = function()
            local wk = require("which-key")
            wk.setup({
                window = {
                    winblend = 30,
                    margin = { 0, 0, 0, 0 },
                    padding = { 1, 1, 1, 1 },
                }
            })
            wk.register({
                ["<leader>f"] = { name = "[F]ind" },
                ["<leader>l"] = { name = "[L]sp" },
                ["<leader>g"] = { name = "[G]it" },
                ["<leader>u"] = { name = "[U]ser Interface" },
                ["<leader>e"] = { name = "[E]xplorer" },
                ["<leader>t"] = { name = "[T]erminal" },
                ["<leader>d"] = { name = "[D]debug" },
                ["<leader>h"] = { name = "[H]arpoon" },
                ["<leader>b"] = { name = "[B]uffer" },
                ["<leader>c"] = { name = "[C]ode" },
            })
        end,
    },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = function()
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			return {}
		end,
	},

    -- Comment Lines with gcc, gcb (line, block)
    {
        "numToStr/Comment.nvim",
        opts = {
            ignore = "^$",
            mappings = {
                basic = true,
                extra = false,
            },
        },
    },

	-- Enhanced t, T, f, F motions
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = true,
		opts = {
			mode = "fuzzy",
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "o", "x" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
		},
	},

	-- Surround
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Buffer Management
	{
		"ThePrimeagen/harpoon",
		keys = {
			{
				"<leader>ha",
				function()
					require("harpoon.mark").add_file()
				end,
				desc = "Harpoon [A]dd",
			},
			{
				"<leader>hq",
				function()
					require("harpoon.ui").toggle_quick_menu()
				end,
				desc = "[Q]uick Menu",
			},
			{
				"[h",
				function()
					require("harpoon.ui").nav_next()
				end,
				desc = "Harpoon Next File",
			},
			{
				"]h",
				function()
					require("harpoon.ui").nav_prev()
				end,
				desc = "Harpoon Next File",
			},
			{
				"<leader>hf",
				":Telescope harpoon marks<cr>",
				desc = "[H]arpoon Finder",
			},
			{
				"<leader>h1",
				function()
					require("harpoon.ui").nav_file(1)
				end,
				desc = "[H]arpoon Goto 1",
			},
			{
				"<leader>h2",
				function()
					require("harpoon.ui").nav_file(2)
				end,
				desc = "[H]arpoon Goto 2",
			},
			{
				"<leader>h3",
				function()
					require("harpoon.ui").nav_file(3)
				end,
				desc = "[H]arpoon Goto 3",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telescope").load_extension("harpoon")
		end,
	},
}

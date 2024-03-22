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
				},
			})
			wk.register({
				["<leader>f"] = { name = "[F]ind" },
				["<leader>l"] = { name = "[L]sp" },
				["<leader>g"] = { name = "[G]it" },
				["<leader>u"] = { name = "[U]set Interface" },
				["<leader>e"] = { name = "[E]xplorer" },
				["<leader>t"] = { name = "[T]erminal" },
				["<leader>d"] = { name = "[D]debug" },
				["<leader>h"] = { name = "[H]arpoon" },
				["<leader>b"] = { name = "[B]buffer" },
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
		"otavioschwanck/arrow.nvim",
		keys = {
			{
				";",
				function()
					require("arrow.ui").openMenu()
				end,
				desc = "Flash",
			},
		},
		opts = {
			show_icons = true,
			-- leader_key = ";", -- Recommended to be a single key
			separate_by_branch = true,
			separate_save_and_remove = true,
		},
	},
	-- Improved yank
	{
		"gbprod/yanky.nvim",
		dependencies = {
			{ "kkharji/sqlite.lua" },
		},
		opts = {
			ring = { storage = "sqlite" },
			highlight = {
				on_put = true,
				on_yank = true,
				timer = 225,
			},
		},
		keys = {
			{
				"<leader>p",
				function()
					require("telescope").extensions.yank_history.yank_history({})
				end,
				desc = "Open Yank History",
			},
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
			{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
			{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
			{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
			{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
			-- { "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
			-- { "<c-n>", "<Plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
			{ "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
			{ "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
			{ "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
			{ "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
			{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
			{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
			{ ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
			{ "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
			{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
			{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
		},
	},
	{
		"Allaman/emoji.nvim",
		keys = {
			{
				"<leader>fee",
				function()
					return require("emoji").insert()
				end,
				desc = "emoji insert",
			},
			{
				"<leader>fek",
				function()
					return require("emoji").insert_kaomoji()
				end,
				desc = "kaomoji insert",
			},
		},
	},
}

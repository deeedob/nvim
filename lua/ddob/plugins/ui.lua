return {

	{
		"nvim-tree/nvim-web-devicons",
	},

	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
            presets = {
                lsp_doc_border = true,
            },
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
			},
			views = {
				cmdline_popup = {
					position = { row = 10, col = "50%" },
					size = { width = 60, height = "auto" },
				},
				popupmenu = {
					relative = "editor",
					position = { row = 12, col = "50%" },
					size = { width = 60, height = 10 },
					border = { style = "rounded", padding = { 0, 1 } },
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
			routes = {
				{
					-- Hide written messages
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
			},
		},
	},

	-- Highlight other
	{
		"RRethy/vim-illuminate",
		opts = {
			delay = 750,
			large_filie_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
			min_count_to_highlight = 2,
		},
		config = function(_, opts)
			require("illuminate").configure(opts)
			vim.keymap.set("n", "[r", function()
				require("illuminate").goto_prev_reference()
			end, { desc = "Prev Reference" })
			vim.keymap.set("n", "]r", function()
				require("illuminate").goto_next_reference()
			end, { desc = "Next Reference" })
		end,
	},

	-- Show color-codes from hex
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},

	-- Smoth scrolling
	{
		"psliwka/vim-smoothie",
		event = "BufRead",
	},
}

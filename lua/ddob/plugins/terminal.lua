return {

	"akinsho/nvim-toggleterm.lua",
	cmd = { "ToggleTerm" },
	keys = {
		{ "<leader>th", "<cmd>ToggleTerm direction=horizontal size=10<cr>", desc = "Terminal Vertical" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal Vertical" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal Float" },
		{ "<leader>ts", "<cmd>TermSelect<cr>", desc = "Select Terminal" },
		{
			"<leader>ta",
			function()
				local terms = require("toggleterm.terminal").get_all(true)
				for _, t in pairs(terms) do
					t:shutdown()
				end
			end,
			desc = "All Terminal Close",
		},
		{
			"<leader>te",
			function()
				local trim_spaces = true
				require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
			end,
			desc = "Terminal Execute",
			mode = "v",
		},
		{ "<C-\\>", "<cmd>exe v:count1 . ToggleTerm<cr>", desc = "Terminal Toggle" },
	},
	config = function()
		require("toggleterm").setup({
			open_mapping = [[<c-\>]],
			size = function(term)
				if term.direction == "horizontal" then
					return 10
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.1
				end
			end,
			hide_numbers = true,
			shell = vim.o.shell,
			shade_terminals = true,
			shading_factor = -20,
			persist_size = true,
			auto_scroll = false,
			start_in_insert = true,
			close_on_exit = true,
			float_opts = { border = "single" },
			highlights = {
				NormalFloat = { link = "NormalFloat" },
				FloatBorder = { link = "FloatBorder" },
				WinBarActive = { link = "WinBar" },
				WinBarInactive = { link = "WinBarNC" },
				MatchParen = { link = "None" },
			},
		})
	end,
}

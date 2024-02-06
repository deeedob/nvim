return {
	{
		"sainnhe/everforest",
		priority = 400,
		config = function()
			vim.g.everforest_background = "hard"
		end,
	},

	{
		"rose-pine/neovim",
		priority = 500,
		name = "rose-pine",
	},

	{
		"sainnhe/gruvbox-material",
		priority = 600,
		config = function()
			vim.cmd([[
                set background=dark
                let g:gruvbox_material_background = "medium"
                let g:gruvbox_material_foreground = "mix"
                let g:gruvbox_material_disable_italic_comment = 1
                let g:gruvbox_material_better_performance = 1
                let g:gruvbox_material_enable_bold = 0
                let g:gruvbox_material_enable_italic = 0
                let g:gruvbox_material_transparent_background = 0
                let g:gruvbox_material_dim_inactive_windows = 0
                let g:gruvbox_material_menu_selection_background = "purple"
                let g:gruvbox_material_sign_column_background = "none"
                let g:gruvbox_material_ui_contrast = "low"
                let g:gruvbox_material_float_style = "dim"
                let g:gruvbox_material_current_word = "grey background"
            ]])
		end,
	},

	{
		"savq/melange-nvim",
		priority = 700,
	},

	{
		"catppuccin/nvim",
		priority = 800,
	},

	{
		"folke/tokyonight.nvim",
		priority = 900,
	},

	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		-- cond = scheme == "kanagawa",
		config = function()
			require("kanagawa").setup({
				colors = {
					-- theme = { all = { ui = { bg_gutter = "none" }} }
					-- theme = { dragon = { ui = { fg = "#EAE7D6" } }}
				},
				overrides = function(colors)
					local cols = require("kanagawa.colors").setup()
					local pal = colors.palette
					local theme = cols.theme
					return {
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },

						-- CursorLine = { bg = theme.ui.bg_p1 },

						NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

						Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
						PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
						PmenuSbar = { bg = theme.ui.bg_m1 },
						PmenuThumb = { bg = theme.ui.bg_p2 },
						-- CmpItemAbbrDeprecated = { fg = theme.syn.comment, strikethrough = false },

						-- -- TODO: add nvim support: https://github.com/loctvl842/monokai-pro.nvim/blob/master/lua/monokai-pro/theme/plugins/neo-tree.lua
						NeoTreeDirectoryIcon = { fg = pal.dragonAsh },
						NeoTreeGitAdded = { fg = pal.dragonOrange },
						NeoTreeDirectoryName = { fg = theme.ui.fg_dim },
					}
				end,
			})
			vim.cmd([[
                " Clear deprecated highlights (had problems in C code with typedef)
                hi! clear DiagnosticDeprecated
                hi! clear NoiceCmdlineIcon
                highlight link IlluminatedWordText CursorLine
                highlight link IlluminatedWordRead CursorLine
                highlight link IlluminatedWordWrite CursorLine
                colorscheme kanagawa
                " highlight DiagnosticSignHint guibg=NONE
                " highlight DiagnosticSignWarn guibg=NONE
                " highlight DiagnosticSignError guibg=NONE
            ]])
		end,
	},
}


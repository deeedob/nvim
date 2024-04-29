local scheme = require("ddob.config").colorscheme

return {
	{
		"sainnhe/everforest",
        cond = scheme.name == "everforest" or scheme.enable_all,
        priority = 1000,
		config = function()
			vim.g.everforest_background = "hard"
		end,
	},

	{
		"rose-pine/neovim",
        cond = scheme.name == "rose-pine" or scheme.enable_all,
        priority = 1000,
		name = "rose-pine",
	},

	{
		"sainnhe/gruvbox-material",
        cond = scheme.name == "gruvbox-material" or scheme.enable_all,
        priority = 1000,
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
        cond = scheme.name == "melange" or scheme.enable_all,
        priority = 1000,
	},

	{
		"catppuccin/nvim",
        cond = scheme.name == "catppuccin" or scheme.enable_all,
        priority = 1000,
	},

	{
		"folke/tokyonight.nvim",
        cond = scheme.name == "tokyonight" or scheme.enable_all,
        priority = 1000,
	},

	{
		-- "rebelot/kanagawa.nvim",
		dir = "~/repos/kanagawa.nvim/",
        cond = scheme.name == "kanagawa" or scheme.enable_all,
        priority = 1000,
		config = function()
			require("kanagawa").setup({
                compile = true,
                dimInactive = true,
				colors = {
					-- theme = { all = { ui = { bg_gutter = "none" }} }
					-- theme = { dragon = { ui = { fg = "#EAE7D6" } }}
				},
				overrides = function(colors)
					local cols = require("kanagawa.colors").setup({
						dimInactive = true,
					})
					local pal = cols.palette
					local theme = cols.theme
					local br = require("ddob.highlights").brighten
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
						WinSeparator = { fg = br(pal.dragonPink, -30) },

						TreesitterContext = { fg = theme.ui.special, bg = br(theme.ui.bg_m1, 10) },
						TreesitterContextLineNumber = { bg = br(theme.ui.bg_gutter, -30) },

						-- -- TODO: add nvim support: https://github.com/loctvl842/monokai-pro.nvim/blob/master/lua/monokai-pro/theme/plugins/neo-tree.lua
						NeoTreeDirectoryIcon = { fg = pal.dragonAsh },
						NeoTreeGitAdded = { fg = pal.dragonOrange },
						NeoTreeDirectoryName = { fg = theme.ui.fg_dim },

						NvimWindowSwitch = { bg = pal.dragonGreen, fg = theme.ui.bg_m3, bold = true },
						NvimWindowSwitchNC = { link = "NvimWindowSwitch" },
						WindowPickerStatusLine = { link = "NvimWindowSwitch" },
						WindowPickerStatusLineNC = { link = "NvimWindowSwitch" },
						WindowPickerWinBar = { link = "NvimWindowSwitch" },
						WindowPickerWinBarNC = { link = "NvimWindowSwitch" },

						IlluminatedWordText = { link = "CursorLine" },
						IlluminatedWordRead = { link = "CursorLine" },
						IlluminatedWordWrite = { link = "CursorLine" },

						DiagnosticFloatingError = { link = "DiagnosticError" },
						DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
						DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
						DiagnosticFloatingHint = { link = "DiagnosticHint" },
						DiagnosticFloatingOk = { link = "DiagnosticOk" },
						CursorLineNr = { fg = br(pal.dragonRed, 20), bg = theme.ui.bg_gutter, bold = false },
                        YankyYanked = { bg = pal.oniViolet, fg = theme.ui.fg_reverse },
                        YankyPut = { bg = pal.oniViolet, fg = theme.ui.fg_reverse },
						-- TODO:
						-- ToggleTerm1FloatBorder = { link = "FloatBorder" },
					}
				end,
			})
			vim.cmd([[
                hi! clear NoiceCmdlineIcon
                colorscheme kanagawa
            ]])
		end,
	},
}

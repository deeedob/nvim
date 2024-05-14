local hl = require("ddob.highlights")

return {
	{
		"b0o/incline.nvim",
		config = function()
			local hlbg = vim.api.nvim_get_hl(0, { name = "Pmenu", create = false })
			local hlfg = vim.api.nvim_get_hl(0, { name = "PreProc", create = false })
			local hlnorm = vim.api.nvim_get_hl(0, { name = "Normal", create = false })

			local col_bg_normal = hl.brighten(hl.colToHexString(hlnorm.bg), -10)
			local col_fg = hl.colToHexString(hlfg.fg)
			local col_bg = hl.colToHexString(hlbg.bg)

			require("incline").setup({
				window = {
					padding = 0,
					margin = { horizontal = 0, vertical = 0 },
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if filename == "" then
						filename = "[No Name]"
					end
					local modified = vim.bo[props.buf].modified
					local res = {
						{ " " .. filename, gui = modified and "strikethrough" or "italic" },
						guibg = props.focused and col_bg or col_bg_normal,
						guifg = col_fg,
					}
					return res
				end,
			})
		end,
		-- Optional: Lazy load Incline
		event = "VeryLazy",
	},
	{
		"nanozuki/tabby.nvim",
		event = "VimEnter",
		dependencies = {
			"tiagovla/scope.nvim", -- buffers are bound to tabs
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>bta", ":$tabnew<cr>", desc = "Add Tab" },
			{ "<leader>bto", ":tabonly<cr>", desc = "Other Tabs Close" },
			{ "<leader>btc", ":tabclose<cr>", desc = "Current Tab Close" },

			{ "}", ":tabn<cr>", desc = "Tab Next" },
			{ "{", ":tabp<cr>", desc = "Tab Prev" },

			{ "]b", ":+tabmove<cr>", desc = "Tab Move Next" },
			{ "[b", ":-tabmove<cr>", desc = "Tab Move Prev" },
		},
		config = function()
			vim.o.showtabline = 2
			require("scope").setup({})

			local util = require("tabby.util")
			local hl_tabline = util.extract_nvim_hl("TabLine")
			local hl_normal = util.extract_nvim_hl("Normal")

			local hl_background = {
				bg = hl.brighten(hl_tabline.bg, 22),
				fg = "NONE",
			}
			local buffer_lighter = hl.brighten(hl_tabline.bg, 30)
			local hl_col = util.extract_nvim_hl("@lsp.type.parameter")

			local theme = {
				fill = hl_background,
				head = hl_tabline,
				win = hl_background,
				tail = "TabLine",

				current_tab = "TabLineSel",
				tab = "TabLine",
				current_buf = { fg = hl_normal.fg, bg = hl_normal.bg, style = "italic" },
				buf = { fg = hl_tabline.fg, bg = buffer_lighter },
				current = { fg = hl_col.fg, bg = hl_background.bg, style = "italic" },
			}
			local highlight = require("tabby.module.highlight")
			local devicons = require("nvim-web-devicons")

			local function ensure_hl_obj(hl)
				if type(hl) == "string" then
					return highlight.extract(hl)
				end
				return hl
			end

			local sep = function(symbol, cur_hl, back_hl)
				local cur_hl_obj = ensure_hl_obj(cur_hl)
				local back_hl_obj = ensure_hl_obj(back_hl)
				return {
					symbol,
					hl = {
						fg = cur_hl_obj.bg,
						bg = back_hl_obj.bg,
					},
				}
			end
			local components = function()
				local cwd = " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
				local coms = {
					{
						type = "text",
						text = {
							cwd,
							hl = theme.head,
						},
					},
					{
						type = "text",
						text = sep("", theme.head, theme.fill),
					},
				}

				-- Tab setup
				local tabs = vim.api.nvim_list_tabpages()
				local current_tab = vim.api.nvim_get_current_tabpage()
				for _, tabid in ipairs(tabs) do
					local hl = theme.tab
					if tabid == current_tab then
						hl = theme.current_tab
					end
					table.insert(coms, {
						type = "text",
						text = sep("", hl, theme.fill),
					})
					table.insert(coms, {
						type = "tab",
						tabid = tabid,
						label = {
							"  " .. vim.api.nvim_tabpage_get_number(tabid) .. "  ",
							hl = hl,
						},
					})
					table.insert(coms, {
						type = "text",
						text = sep("", hl, theme.fill),
					})
				end
				table.insert(coms, {
					type = "text",
					text = {
						" ",
						hl = theme.fill,
					},
				})
				table.insert(coms, { type = "spring" })

				-- Current buffer
				local cur_bufid = vim.api.nvim_get_current_buf()
				table.insert(coms, {
					type = "text",
					text = {
						vim.fn.expand("%:."), -- get current bufname local to project dir
						hl = theme.current,
					},
				})

				table.insert(coms, {
					type = "text",
					text = {
						" ",
						hl = theme.fill,
					},
				})
				table.insert(coms, { type = "spring" })

				-- Buf setup
				for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(bufid) and vim.bo[bufid].buflisted then
						local hl = theme.buf
						if bufid == cur_bufid then
							hl = theme.current_buf
						end
                        local fname = vim.api.nvim_buf_get_name(bufid)
						local filename = vim.fn.fnamemodify(fname, ":t")
						local ext = vim.fn.fnamemodify(fname, ":e")
						local icon, icon_hl = devicons.get_icon(filename, ext)
                        if not icon then
                            icon = ""
                            icon_hl = hl
                        end

						table.insert(coms, {
							type = "text",
							text = sep("", hl, theme.fill),
						})
						table.insert(coms, {
							type = "text",
							text = {
								" " .. icon .. " ",
								hl = icon_hl,
							},
						})
						table.insert(coms, {
							type = "text",
							text = sep("", hl, theme.fill),
						})
					end
				end
				table.insert(coms, {
					type = "text",
					text = sep("", theme.tail, theme.fill),
				})
				table.insert(coms, {
					type = "text",
					text = {
						"   ",
						hl = theme.tail,
					},
				})
				return coms
			end

			require("tabby").setup({
				components = components,
			})
		end,
	},
	{
		"caenrique/swap-buffers.nvim",
		keys = {
			{
				"<leader>bh",
				function()
					require("swap-buffers").swap_buffers("h")
				end,
				desc = "Buffer Swap Left",
			},
			{
				"<leader>bj",
				function()
					require("swap-buffers").swap_buffers("j")
				end,
				desc = "Buffer Swap Down",
			},
			{
				"<leader>bk",
				function()
					require("swap-buffers").swap_buffers("k")
				end,
				desc = "Buffer Swap Top",
			},
			{
				"<leader>bl",
				function()
					require("swap-buffers").swap_buffers("l")
				end,
				desc = "Buffer Swap Right",
			},
		},
		opts = {
			-- print(vim.bo.filetypes)
			ignore_filetypes = { "neo-tree", "toggleterm", "Trouble" },
		},
	},
}

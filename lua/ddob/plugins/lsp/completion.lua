local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- https://github.com/hrsh7th/nvim-cmp/issues/156
local lspkind_comparator = function(conf)
	local lsp_types = require("cmp.types").lsp
	return function(entry1, entry2)
		if entry1.source.name ~= "nvim_lsp" then
			if entry2.source.name == "nvim_lsp" then
				return false
			else
				return nil
			end
		end
		local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
		local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]

		local priority1 = conf.kind_priority[kind1] or 0
		local priority2 = conf.kind_priority[kind2] or 0
		if priority1 == priority2 then
			return nil
		end
		return priority2 < priority1
	end
end

local label_comparator = function(entry1, entry2)
	return entry1.completion_item.label < entry2.completion_item.label
end

return {
	{
		"hrsh7th/nvim-cmp",
		version = false,
		event = "InsertEnter",
		dependencies = {
			"onsails/lspkind.nvim", -- icons
			"neovim/nvim-lspconfig",

			"hrsh7th/cmp-nvim-lsp",
			-- TODO: Not required anymore?
			-- "hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",

			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",

			"p00f/clangd_extensions.nvim",
			{
				"Saecki/crates.nvim",
				event = { "BufRead Cargo.toml" },
				opts = { src = { cmp = { enabled = true } } },
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			-- Icons
			require("luasnip.loaders.from_vscode").lazy_load()
			luasnip.config.setup({
				history = true,
				update_events = "TextChanged,TextChangedI",
			})

			cmp.setup({
				-- Disable on comments
				enabled = function()
					local ctx = require("cmp.config.context")
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					else
						return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
					end
				end,
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				view = { entries = "custom" },
				mapping = {
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<C-CR>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
				},
				formatting = {
					expandable_indicator = true,
					fields = { "kind", "abbr", "menu" },
					format = require("lspkind").cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						before = function(entry, vim_item)
							local m = vim_item.menu and vim_item.menu or ""
							if #m > 20 then
								vim_item.menu = string.sub(m, 1, 20) .. "..."
							end
							return vim_item
						end,
					}),
				},
				sources = {
					{ name = "nvim_lsp" },
					-- { name = "nvim_lsp_signature_help" },
					{ name = "luasnip" },
					{ name = "path", option = { trailing_slash = true } },
					{ name = "crates" },
				},
				sorting = {
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.recently_used,
						require("clangd_extensions.cmp_scores"),
						cmp.config.compare.kind,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				experimental = {
					ghost_text = {
						hl_group = "Comment",
					},
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path", option = { trailing_slash = true } },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
}

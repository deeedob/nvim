local servers = {
	"clangd",
	"neocmake",
	"pyright",
	"lua_ls",
	"bashls",
	"marksman",
	"rust_analyzer",
	"jsonls",
	"buf",
}

return {
	-- Lsp Installer
	{
		"williamboman/mason.nvim",
		cmd = { "Mason" },
		event = "VeryLazy",
		build = function()
			pcall(function()
				require("mason-registry").refresh()
			end)
		end,
		init = function()
			vim.api.nvim_create_user_command("MasonInstallExtras", function()
				vim.cmd(
					"MasonInstall clang-format cmakelang cmakelint stylua ruff shellharden shellcheck codespell prettier buf markdownlint"
				)
			end, { desc = "Mason Install Extras (fmt & linters)" })
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
	},

	-- Diagnostic List
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "TroubleToggle" },
		keys = {
			{ "<leader>lT", "<cmd>TroubleToggle<cr>", desc = "[T]rouble Toggle" },
		},
		opts = {
			mode = "document_diagnostics",
		},
	},

	{
		"hedyhli/outline.nvim",
		cmd = { "Outline", "OutlineOpen" },
		keys = {
			{ "<leader>ls", "<cmd>Outline<CR>", desc = "Toggle outline" },
		},
		opts = {},
	},

	-- Easy lua-nvim-lsp setup
	{
		"folke/neodev.nvim",
	},

	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local dconf = require("ddob.config")
			require("neodev").setup({
				-- library = { plugins = { "nvim-dap-ui" }, types = true },
			})

			require("mason").setup()
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = servers,
				automatic_installation = true,
			})

			-- Diagnostics config
			vim.diagnostic.config({
				underline = true,
				virtual_text = false,
				signs = true,
				update_in_insert = true,
				severity_sort = true,
				float = {
					scope = "line",
					border = "rounded",
					header = "",
					prefix = " ",
					focusable = false,
					source = "always",
				},
			})

			-- Diagnostic style
			if dconf.lsp.icon_sign then
				for type, icon in pairs(dconf.icons.diagnostics) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = "", texthl = hl, numhl = hl })
				end
			else -- Highlight with icons in sign column
				vim.cmd([[
                    " -- https://stackoverflow.com/questions/18774910/how-to-partially-link-highlighting-groups
                    " This here sets the highlighting group partially, so
                    " that we can set an individual background. Kinda funky
                    exec 'hi ColumnDiagnosticError guibg=#2a2a37 ' . 'guifg=' . synIDattr(hlID('DiagnosticError'),'fg')
                    exec 'hi ColumnDiagnosticWarn guibg=#2a2a37 ' . 'guifg=' . synIDattr(hlID('DiagnosticWarn'),'fg')
                    exec 'hi ColumnDiagnosticInfo guibg=#2a2a37 ' . 'guifg=' . synIDattr(hlID('DiagnosticInfo'),'fg')
                    exec 'hi ColumnDiagnosticHint guibg=#2a2a37 ' . 'guifg='. synIDattr(hlID('DiagnosticHint'),'fg')
                    hi link SyntasticErrorLine SignColumn
                ]])
				for _, diag in ipairs({ "Error", "Warn", "Info", "Hint" }) do
					vim.fn.sign_define("DiagnosticSign" .. diag, {
						text = "",
						texthl = "ColumnDiagnostic" .. diag,
						linehl = "",
						numhl = "ColumnDiagnostic" .. diag,
					})
				end
			end

			-- Better refresh in nvim 0.10
			vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
				local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
				local bufnr = vim.api.nvim_get_current_buf()
				vim.diagnostic.reset(ns, bufnr)
				return true
			end

			-- Attach function for LSP
			local on_attach_default = function(client, bufnr)
				-- LSP-related key mappings
				-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#serverCapabilities
				if client.server_capabilities.hoverProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs", buffer = bufnr })
				end
				if client.server_capabilities.codeActionProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"<leader>la",
						vim.lsp.buf.code_action,
						{ desc = "Code [A]ctions", buffer = bufnr }
					)
				end
				if client.server_capabilities.renameProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "[R]ename", buffer = bufnr })
				end
				if client.server_capabilities.documentSymbolProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"<leader>lD",
						require("telescope.builtin").lsp_document_symbols,
						{ desc = "[D]ocument Symbols", buffer = bufnr }
					)
				end
				if client.server_capabilities.typeDefinitionProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"<leader>lt",
						require("telescope.builtin").lsp_type_definitions,
						{ desc = "[T]ype definition", buffer = bufnr }
					)
				end
				if client.server_capabilities.definitionProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"gd",
						require("telescope.builtin").lsp_definitions,
						{ desc = "Goto [D]efinition", buffer = bufnr }
					)
					vim.keymap.set(
						"n",
						"gdv",
						":vsplit | lua vim.lsp.buf.definition()<CR>",
						{ desc = "Goto [D]efinition Vertical", buffer = bufnr }
					)
					vim.keymap.set(
						"n",
						"gdh",
						":belowright split | lua vim.lsp.buf.definition()<CR>",
						{ desc = "Goto [D]efinition Horizontal", buffer = bufnr }
					)
				end
				if client.server_capabilities.implementationProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"gi",
						require("telescope.builtin").lsp_implementations,
						{ desc = "Goto [I]mplementations", buffer = bufnr }
					)
				end
				if client.server_capabilities.declarationProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto [D]eclaration", buffer = bufnr })
				end
				if client.server_capabilities.signatureHelpProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"<C-s>",
						vim.lsp.buf.signature_help,
						{ desc = "Signature Help", buffer = bufnr }
					)
				end
				if client.server_capabilities.referencesProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"gr",
						require("telescope.builtin").lsp_references,
						{ desc = "Goto [R]eferences", buffer = bufnr }
					)
				end
				if client.server_capabilities.callHierarchyProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"<leader>lci",
						vim.lsp.buf.incoming_calls,
						{ desc = "[I]ncoming Calls", buffer = bufnr }
					)
					vim.keymap.set(
						"n",
						"<leader>lco",
						vim.lsp.buf.outgoing_calls,
						{ desc = "[O]outgoing Calls", buffer = bufnr }
					)
				end
				if client.server_capabilities.diagnosticProvider or dconf.lsp.skip_capability_check then
					vim.keymap.set(
						"n",
						"<leader>ld",
						vim.diagnostic.open_float,
						{ desc = "[D]iagnostic Line", buffer = bufnr }
					)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic Prev", buffer = bufnr })
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic Next", buffer = bufnr })
					if dconf.lsp.hover_diagnostic then
						vim.api.nvim_create_autocmd("CursorHold", {
							group = vim.api.nvim_create_augroup("ddob_diagnostic_hover", { clear = true }),
							buffer = bufnr,
							callback = function()
								local opts = {
									focusable = false,
									close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
									border = "rounded",
									source = "always",
									prefix = " ",
									scope = "line",
								}
								vim.diagnostic.open_float(nil, opts)
							end,
						})
					end
				end
			end

			-- Capabilities for auto-completion
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			mason_lspconfig.setup_handlers({
				function(server_name)
					if server_name ~= "rust_analyzer" then
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
							on_attach = on_attach_default,
							filetypes = (servers[server_name] or {}).filetypes,
						})
					end
				end,
				["clangd"] = function()
					local lspconfig = require("lspconfig")
					local capacopy = vim.deepcopy(capabilities)
					capacopy.offsetEncoding = { "utf-16" }
					lspconfig.clangd.setup({
						capabilities = capacopy,
						on_attach = on_attach_default,
						on_new_config = function(conf, dir)
							local status, cmake = pcall(require, "cmake-tools")
							if status then
								cmake.clangd_on_new_config(conf)
							end
						end,
						filetypes = { "c", "cpp", "objc", "objcpp" },
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=never",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--cross-file-rename",
							"--enable-config",
                            "--query-driver=/usr/bin/clang++",
							"-j=4",
						},
						init_options = {
							usePlaceholders = true,
							completeUnimported = true,
							clangdFileStatus = true,
						},
					})
				end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						on_attach = on_attach_default,
						settings = {
							Lua = {
								workspace = { checkThirdParty = false },
								telemetry = { enable = false },
								diagnostics = { disable = { "missing-fields" } },
							},
						},
					})
				end,
				["rust_analyzer"] = function()
					local lspconfig = require("lspconfig")
					local util = require("lspconfig.util")
					lspconfig.rust_analyzer.setup({
						capabilities = capabilities,
						on_attach = on_attach_default,
						filetypes = { "rust" },
						root_dir = util.root_pattern("Cargo.toml"),
						settings = {
							["rust-analyzer"] = {
								cargo = {
									allFeatures = true,
									loadOutDirsFromCheck = true,
									runBuildScripts = true,
								},
								checkOnSave = {
									allFeatures = true,
									command = "clippy",
									extraArgs = { "--no-deps" },
								},
								procMacro = {
									enable = true,
									ignored = {
										["async-trait"] = { "async_trait" },
										["napi-derive"] = { "napi" },
										["async-recursion"] = { "async_recursion" },
									},
								},
							},
						},
					})
				end,
			})

			local function qml_root_dir()
				if package.loaded["cmake-tools"] then
					return require("cmake-tools").get_build_directory().filename
				end
				return vim.fn.getcwd()
			end
			require("lspconfig").qmlls.setup({
				cmd = { "qmlls", "-b", qml_root_dir() },
				filetypes = { "qml" },
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.find_git_ancestor(fname)
				end,
				single_file_support = true,
			})
		end,
	},
}

-- Get lua user config directory
local nvim_config_path = vim.fn.stdpath("config")

return {
	{
		dir = "~/repos/cmake-tools.nvim",
		-- "Civitasv/cmake-tools.nvim",
		ft = { "cmake", "cpp" },
		keys = {
			{ "<leader>cg", ":CMakeGenerate<CR>", desc = "CMake Configure" },
			{ "<leader>cb", ":CMakeBuild<CR>", desc = "CMake Build" },
			{ "<leader>cr", ":CMakeRun<CR>", desc = "CMake Run" },
			{ "<leader>cd", ":CMakeDebug<CR>", desc = "CMake Debug" },

			{ "<leader>cG", ":CMakeGenerate!<CR>", desc = "CMake Force Configure" },
			{ "<leader>cB", ":CMakeBuild!<CR>", desc = "CMake Force Build" },
			{ "<leader>cR", ":CMakeQuickRun<CR>", desc = "CMake Quick Run" },
			{ "<leader>cD", ":CMakeQuickDebug<CR>", desc = "CMake Quick Debug" },

			{ "<leader>ck", ":CMakeStop<CR>", desc = "CMake Kill" },
			{ "<leader>cc", ":CMakeClean<CR>", desc = "CMake Clean" },

			{ "<leader>csr", ":CMakeSelectLaunchTarget<CR>", desc = "CMake Select Run Target" },
			{ "<leader>csb", ":CMakeSelectBuildTarget<CR>", desc = "CMake Select Build Target" },
			{ "<leader>cst", ":CMakeSelectBuildType<CR>", desc = "CMake Select Build Type" },
			{ "<leader>csk", ":CMakeSelectKit<CR>", desc = "CMake Select Kit" },
			{ "<leader>csf", ":CMakeShowTargetFiles<CR>", desc = "CMake Show Target's files" },
			{ "<leader>css", ":CMakeSettings<CR>", desc = "CMake Project Settings" },
			{ "<leader>csc", ":CMakeSelectConfigurePreset<CR>", desc = "CMake Configure Preset" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = function()
			-- Toggle List Characters Command
			vim.api.nvim_create_user_command("CMakeWipe", function()
				local build_dir = require("cmake-tools").get_build_directory()
				local cmd = "rm -rf " .. build_dir.filename
				print(cmd)
				-- vim.fn.execute(cmd)
				vim.fn.system(cmd)
				vim.cmd([[CMakeGenerate]])
				-- vim.fn.execute("rm -rf")
			end, { desc = "Wipe build dir and start fresh" })

			vim.keymap.set("n", "<leader>cw", ":CMakeWipe<cr>", { desc = "Wipe Build Dir", remap = true })

			return {
				cmake_command = "cmake",
				cmake_regenerate_on_save = true,
				-- cmake_generate_options = { "" },
				cmake_build_options = { "-j4" },
				cmake_build_directory = "cmake-build/${variant:buildType}",
				cmake_soft_link_compile_commands = false,
				cmake_compile_commands_from_lsp = true,
				cmake_kits_path = nvim_config_path .. "/res/cmake-kits.json",
				cmake_dap_configuration = {
					name = "cpp",
					type = "codelldb",
					request = "launch",
					stopOnEntry = false,
					runInTerminal = true,
					console = "integratedTerminal",
				},
				cmake_executor = {
					name = "toggleterm",
					opts = {
						direction = "horizontal",
						auto_scroll = false,
						close_on_exit = false,
					},
				},
				cmake_runner = {
					name = "toggleterm",
					opts = {
						direction = "horizontal",
						auto_scroll = false,
						close_on_exit = false,
					},
				},
				cmake_notifications = {
					runner = { enabled = false },
					executor = { enabled = false },
				},
			}
		end,
	},

	{
		"gauteh/vim-cppman",
		ft = { "c", "cpp", "objc", "objcpp", "cuda" },
		config = function(_, opts)
			vim.keymap.set("n", "KK", function()
				local word = vim.fn.expand("<cword>")
				local escaped_word = vim.fn.fnameescape(word)
				vim.cmd("Cppman " .. escaped_word)
			end, { desc = "Open cppman" })
		end,
	},

	-- Enhanced clangd
	{
		"p00f/clangd_extensions.nvim",
		filetypes = { "cpp", "c" },
		keys = {
			{ "<leader>ll", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
			{ "<leader>lA", "<cmd>ClangdAST<cr>", desc = "AST toggle" },
			{ "<leader>ui", "<cmd>ClangdToggleInlayHints<cr>", desc = "LSP Toggle Inlay Hints" },
		},
		opts = {
			inlay_hints = { inline = false },
			ast = {
				-- requires codicons
				role_icons = {
					type = "",
					declaration = "",
					expression = "",
					specifier = "",
					statement = "",
					["template argument"] = "",
				},
				kind_icons = {
					Compound = "",
					Recovery = "",
					TranslationUnit = "",
					PackExpansion = "",
					TemplateTypeParm = "",
					TemplateTemplateParm = "",
					TemplateParamObject = "",
				},
			},
		},
	},
}

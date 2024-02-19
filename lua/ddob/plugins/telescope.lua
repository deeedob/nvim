return {
	"nvim-telescope/telescope.nvim",
	version = false,
	cmd = "Telescope",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"debugloop/telescope-undo.nvim",
	},
	keys = {
		{
			"<leader>fw",
			function()
				return require("telescope.builtin").live_grep({})
			end,
			desc = "words (root)",
		},
		{
			"<leader>fW",
			function()
				return require("telescope.builtin").live_grep({
					cwd = require("telescope.utils").buffer_dir(),
				})
			end,
			desc = "words (current)",
		},
		{
			"<leader>ft",
			function()
				return require("telescope.builtin").live_grep({
					type_filter = vim.bo.filetype,
				})
			end,
			desc = "word in filetype",
		},
		{
			"<leader>fT",
			function()
				return require("telescope.builtin").live_grep({
					type_filter = vim.bo.filetype,
					search_dirs = { "/" },
					disable_coordinates = true,
				})
			end,
			desc = "word in filetype (global)",
		},
		{
			"<leader>ff",
			function()
				return require("telescope.builtin").find_files({})
			end,
			desc = "files (root)",
		},
		{
			"<leader>fF",
			function()
				return require("telescope.builtin").find_files({
					cwd = require("telescope.utils").buffer_dir(),
				})
			end,
			desc = "files (current)",
		},
		{
			"<leader>f/",
			function()
				return require("telescope.builtin").current_buffer_fuzzy_find({
					skip_empty_lines = true,
				})
			end,
			desc = "current buffer fuzzy",
		},
		{
			"<leader>fb",
			function()
				return require("telescope.builtin").buffers({
					sort_lastused = true,
				})
			end,
			desc = "buffers",
		},
		{
			"<leader>fr",
			function()
				return require("telescope.builtin").resume()
			end,
			desc = "resume",
		},
		{
			"<leader>fR",
			function()
				return require("telescope.builtin").oldfiles()
			end,
			desc = "recently opened",
		},
		{
			"<leader>fh",
			function()
				return require("telescope.builtin").help_tags()
			end,
			desc = "help",
		},
		{
			"<leader>fm",
			function()
				return require("telescope.builtin").man_pages()
			end,
			desc = "man pages",
		},
		{
			"<leader>fk",
			function()
				return require("telescope.builtin").keymaps()
			end,
			desc = "keymaps",
		},
		{
			"<leader>fc",
			function()
				return require("telescope.builtin").commands()
			end,
			desc = "commands",
		},
		{
			"<leader>fC",
			function()
				return require("telescope.builtin").command_history()
			end,
			desc = "command history",
		},

		{
			"<leader>fd",
			function()
				return require("telescope.builtin").diagnostics({ bufnr = 0 })
			end,
			desc = "diagnostics (local)",
		},
		{
			"<leader>fD",
			function()
				return require("telescope.builtin").diagnostics()
			end,
			desc = "workspace diagnostics (global)",
		},
		{
			"<leader>fs",
			function()
				return require("telescope.builtin").lsp_document_symbols()
			end,
			desc = "symbols",
		},
		{
			"<leader>fS",
			function()
				return require("telescope.builtin").colorscheme({
					enable_preview = true,
				})
			end,
			desc = "colorscheme",
		},
		{
			"<leader>fH",
			function()
				return require("telescope.builtin").highlights()
			end,
			desc = "highlights",
		},
		{
			"<leader>fu",
			function()
				return require("telescope").extensions.undo.undo()
			end,
			desc = "highlights",
		},

		-- Git bindings
		{
			"<leader>gc",
			function()
				return require("telescope.builtin").git_commits()
			end,
			desc = "find commit",
		},
		{
			"<leader>gC",
			function()
				return require("telescope.builtin").git_bcommits()
			end,
			desc = "find commit (current)",
		},
		{
			"<leader>gc",
			function()
				local utils = require("ddob.utils")
				local b, e = utils.get_visual_pos()
				return require("telescope.builtin").git_bcommits_range({
					from = b[1],
					to = e[1],
				})
			end,
			mode = { "v" },
			desc = "find commit in range",
		},
		{
			"<leader>gb",
			function()
				return require("telescope.builtin").git_branches()
			end,
			desc = "find branches",
		},
		{
			"<leader>gB",
			function()
				return require("telescope.builtin").git_branches({
					show_remote_tracking_branches = false,
				})
			end,
			desc = "find branches (local)",
		},
		{
			"<leader>gs",
			function()
				return require("telescope.builtin").git_status()
			end,
			desc = "find status",
		},
		{
			"<leader>gS",
			function()
				return require("telescope.builtin").git_stash()
			end,
			desc = "find stash",
		},
	},
	opts = function()
		require("which-key").register({
			["<leader>g"] = { name = "[G]it" },
		}, { mode = "v" })
		local ts_conf = require("telescope.config")
		local grep_args = { unpack(ts_conf.values.vimgrep_arguments) }
		-- I want to search in hidden/dot files.
		table.insert(grep_args, "--hidden")
		-- I don't want to search in the `.git` directory.
		table.insert(grep_args, "--glob")
		table.insert(grep_args, "!**/.git/*")

		local actions = require("telescope.actions")
		require("telescope").load_extension("undo")

		return {
			extensions = {
				undo = {
					use_delta = true,
				},
			},
			defaults = {
				prompt_prefix = " ",
				selection_caret = "> ",
				mappings = {
					n = { ["q"] = actions.close },
				},
				vimgrep_arguments = grep_args,
				-- path_display = { "shorten" },
				file_ignore_patterns = { ".git/" },
				layout_config = { prompt_position = "top" },
			},
			pickers = {
				colorscheme = {
					enable_preview = true, -- doesn't work?
				},
				find_files = {
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
			},
		}
	end,
}

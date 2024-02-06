return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		keys = {
			{
				"<C-n>",
				function()
					require("neo-tree.command").execute({ position = "left", toggle = true })
				end,
				desc = "[E]xplorer NeoTree",
			},
			{
				"<leader>eb",
				function()
					require("neo-tree.command").execute({ source = "buffers", toggle = true })
				end,
				desc = "[B]buffers Explorer ",
			},
			{
				"<leader>eg",
				function()
					require("neo-tree.command").execute({ source = "git_status", toggle = true })
				end,
				desc = "[G]it Explorer ",
			},
			-- Open the file under cursor
			{
				"<leader>ef",
				function()
					local f = vim.fn.expand("%:p")
					require("neo-tree.command").execute({
						position = "float",
						reveal_file = f,
						reveal_force_cwd = true,
					})
				end,
				desc = " [F]ile Explorer",
			},
		},
		deactivate = function()
			vim.cmd([[Neotree close]])
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			close_if_last_window = true,
			sources = { "filesystem", "buffers", "git_status", "document_symbols" },
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "edgy" },
			enable_git_status = true,
			enable_diagnostics = false,
			enable_normal_mode_for_inputs = false,
			git_status_async_options = {
				batch_size = 1000,
				batch_delay = 10,
				max_lines = 10000,
			},

			source_selector = {
				winbar = true,
				sources = {
					{
						source = "filesystem",
                        display_name = "  "
					},
					{
						source = "buffers",
						display_name = " 󰥛 ",
					},
                    {
                        source = "document_symbols",
						display_name = " 󱑻 ",
                    },
					{
						source = "git_status",
						display_name = " 󰊢 ",
					},
				},
			},

			default_component_configs = {
				icon = {
					folder_closed = "󰉖",
					folder_open = "󰷏",
					folder_empty = "󱧹",
					folder_empty_open = "󱧹",
				},
				modified = {
					symbol = " ",
					highlight = "NeoTreeModified",
				},
				name = { trailing_slash = true },
				git_status = {
					symbols = {
						-- Change type
						added = "", -- redundant due to colored name
						modified = "",
						deleted = "D",
						renamed = "R",
						-- Status type
						untracked = "󰰧 ",
						unstaged = " ",
						staged = " ",
						conflict = " ",
						ignored = "",
					},
				},
				symlink_target = { enabled = false },
				-- Extra metrics
				file_size = { enabled = false },
				type = { enabled = false },
				created = { enabled = false },
				last_modified = {
					enabled = true,
					required_width = 70,
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = false,
					leave_dirs_open = true,
				},
				group_empty_dirs = false,
				use_libuv_file_watcher = true,
				find_by_full_path_words = false,
				window = {
					width = 20,
					mappings = {
						["o"] = "system_open", -- Open the current file by the OS' default tool.
						["i"] = "run_command", -- Expand file on cmd line
						["D"] = "diff_files", -- Diff two files
						["t"] = "trash",
						["/"] = "noop",
						["<leader>/"] = "filter_as_you_type",
						["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
					},
				},
				commands = {
					system_open = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.jobstart({ "xdg-open", path }, { detach = true })
					end,
					run_command = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.api.nvim_input(": " .. path .. "<Home>")
					end,
					diff_files = function(state)
						local node = state.tree:get_node()
						local log = require("neo-tree.log")
						state.clipboard = state.clipboard or {}
						if diff_Node and diff_Node ~= tostring(node.id) then
							local current_Diff = node.id
							require("neo-tree.utils").open_file(state, diff_Node, open)
							vim.cmd("vert diffs " .. current_Diff)
							log.info("Diffing " .. diff_Name .. " against " .. node.name)
							diff_Node = nil
							current_Diff = nil
							state.clipboard = {}
							require("neo-tree.ui.renderer").redraw(state)
						else
							local existing = state.clipboard[node.id]
							if existing and existing.action == "diff" then
								state.clipboard[node.id] = nil
								diff_Node = nil
								require("neo-tree.ui.renderer").redraw(state)
							else
								state.clipboard[node.id] = { action = "diff", node = node }
								diff_Name = state.clipboard[node.id].node.name
								diff_Node = tostring(state.clipboard[node.id].node.id)
								log.info("Diff source file " .. diff_Name)
								require("neo-tree.ui.renderer").redraw(state)
							end
						end
					end,
					trash = function(state)
						local inputs = require("neo-tree.ui.inputs")
						local path = state.tree:get_node().path
						local msg = "Are you sure you want to trash " .. path
						inputs.confirm(msg, function(confirmed)
							if not confirmed then
								return
							end
							vim.fn.system({ "trash", vim.fn.fnameescape(path) })
							require("neo-tree.sources.manager").refresh(state.name)
						end)
					end,
				},
				filtered_items = {
					always_show = {
						".gitignored",
						"CMakePresets.json",
						".vscode",
					},
				},
				components = {
					harpoon_index = function(config, node, state)
						local Marked = require("harpoon.mark")
						local path = node:get_id()
						local success, index = pcall(Marked.get_index_of, path)
						if success and index and index > 0 then
							return {
								text = string.format("%d ", index), -- <-- Add your favorite harpoon like arrow here
								highlight = config.highlight or "NeoTreeDirectoryIcon",
							}
						else
							return {}
						end
					end,
				},

				renderers = {
					file = {
						{ "indent" },
						{ "icon" },
						{
							"container",
							content = {
								{
									"name",
									zindex = 10,
								},
								{
									"symlink_target",
									zindex = 10,
									highlight = "NeoTreeSymbolicLinkTarget",
								},
								{ "git_status", zindex = 10, align = "right" },
								{ "modified", zindex = 20, align = "right" },
								{ "harpoon_index", zindex = 10, align = "right" },
								{ "last_modified", zindex = 10, align = "right" },
								{ "file_size", zindex = 10, align = "right" },
								{ "type", zindex = 10, align = "right" },
								{ "created", zindex = 10, align = "right" },
							},
						},
					},
				},
			},
		},
	},
	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
	},
}

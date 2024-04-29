return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function()
            local cmake = nil
            if package.loaded["cmake-tools"] then
                cmake = require("cmake-tools")
            end

            -- local cmake = require("cmake-tools")
			local icons = require("wayn.config").icons
			local col = require("wayn.config").colors.cmake_line
			local conditions = {
				buffer_not_empty = function()
					return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
				end,
				min_window_width = function(width)
					return vim.fn.winwidth(0) > width
				end,
			}
			local hide_cmake = 120
			return {
				options = {
					theme = "auto",
					globalstatus = true,
					component_separators = "",
					section_separators = { left = "", right = "" },
					always_divide_middle = false,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						-- {
						-- 	"filename",
						-- 	cond = conditions.buffer_not_empty,
						-- 	color = { gui = "bold" },
						-- 	-- padding = { left = 1, right = 2 }
						-- },
						{
							function()
                                if not cmake then return "" end
								local b_target = cmake.get_build_target()
								return (b_target and b_target or "X")
							end,
							cond = function()
                                if not cmake then return "" end
								return conditions.min_window_width(hide_cmake) and cmake.is_cmake_project()
							end,
							icon = icons.cmake.Gear,
							color = { fg = col },
							on_click = function(n, mouse)
								if n == 1 then
									if mouse == "l" then
										vim.cmd("CMakeSelectBuildTarget")
									end
								end
							end,
						},
						{
							function()
                                if not cmake then return "" end
								local l_target = cmake.get_launch_target()
								return (l_target and l_target or "X")
							end,
							icon = icons.cmake.Run,
							cond = function()
                                if not cmake then return "" end
								return conditions.min_window_width(hide_cmake) and cmake.is_cmake_project()
							end,
							color = { fg = col },
							on_click = function(n, mouse)
								if n == 1 then
									if mouse == "l" then
										vim.cmd("CMakeSelectLaunchTarget")
									end
								end
							end,
						},
						-- Middle
						{
							"%=",
							cond = function()
								return conditions.min_window_width(60)
							end,
						},
					},
					lualine_x = {
						{
							function()
                                if not cmake then return "" end
								local kit = cmake.get_kit()
								return (kit and kit or "X")
							end,
							icon = icons.cmake.Arch,
							cond = function()
                                if not cmake then return false end
								return conditions.min_window_width(hide_cmake)
									and cmake.is_cmake_project()
									and not cmake.has_cmake_preset()
							end,
							color = { fg = col },
							on_click = function(n, mouse)
								if n == 1 then
									if mouse == "l" then
										vim.cmd("CMakeSelectKit")
									end
								end
							end,
						},
						{
							function()
                                if not cmake then return "" end
								local c_preset = cmake.get_configure_preset()
								return (c_preset and c_preset or "X")
							end,
							icon = icons.cmake.Build,
							cond = function()
                                if not cmake then return "" end
								return conditions.min_window_width(hide_cmake)
									and cmake.is_cmake_project()
									and cmake.has_cmake_preset()
							end,
							color = { fg = col },
							on_click = function(n, mouse)
								if n == 1 then
									if mouse == "l" then
										vim.cmd("CMakeSelectConfigurePreset")
									end
								end
							end,
						},
						{
							function()
                                if not cmake then return "" end
								local type = cmake.get_build_type()
								return " " .. (type and type or "")
							end,
							icon = icons.cmake.Build,
							cond = function()
                                if not cmake then return false end
								return conditions.min_window_width(hide_cmake)
									and cmake.is_cmake_project()
									and not cmake.has_cmake_preset()
							end,
							color = { fg = col },
							on_click = function(n, mouse)
								if n == 1 then
									if mouse == "l" then
										vim.cmd("CMakeSelectBuildType")
									end
								end
							end,
						},
						{
							function()
                                if not cmake then return "" end
								local b_preset = cmake.get_build_preset()
								return (b_preset and b_preset or "X")
							end,
							cond = function()
                                if not cmake then return false end
								return conditions.min_window_width(hide_cmake)
									and cmake.is_cmake_project()
									and cmake.has_cmake_preset()
							end,
							color = { fg = col },
							on_click = function(n, mouse)
								if n == 1 then
									if mouse == "l" then
										vim.cmd("CMakeSelectBuildPreset")
									end
								end
							end,
						},
					},
					lualine_y = {
						{
							function()
								local msg = "No Active Lsp"
								local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
								local clients = vim.lsp.get_active_clients()
								if next(clients) == nil then
									return msg
								end
								for _, client in ipairs(clients) do
									local filetypes = client.config.filetypes
									if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
										return client.name
									end
								end
								return msg
							end,
							icon = "",
							color = { gui = "bold" },
							cond = function()
								return conditions.min_window_width(60)
							end,
						},
						{
							"diagnostics",
							symbols = {
								error = icons.diagnostics.Error,
								warn = icons.diagnostics.Warn,
								info = icons.diagnostics.Info,
								hint = icons.diagnostics.Hint,
							},
						},
						{
							"diff",
							symbols = {
								added = icons.git.added,
								modified = icons.git.modified,
								removed = icons.git.removed,
							},
							source = function()
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
					},
					lualine_z = {
						-- { "progress" },
						{ "location" },
					},
				},
                -- extensions = { "toggleterm", "fugitive", "nvim-dap-ui", "trouble", "lazy" }
			}
		end,
	},
}

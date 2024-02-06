---@diagnostic disable: missing-fields

---@type string
local xdg_config = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"

---@param path string
local function have(path)
	return vim.loop.fs_stat(xdg_config .. "/" .. path) ~= nil
end

return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		init = function()
			-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
			vim.defer_fn(function()
				vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"
				require("nvim-treesitter.configs").setup({
					-- Add languages to be installed here that you want installed for treesitter
					ensure_installed = {
						"c",
						"cpp",
                        "rust",
						"lua",
						"python",
						"vimdoc",
						"vim",
						"bash",
                        "regex",
						"markdown",
						"markdown_inline",
						"diff",
						"vimdoc",
						"yaml",
						"fish",
						"proto",
                        "qmldir",
                        "qmljs",
                        "ron",
                        "toml",
					},

					-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
					auto_install = true,

					highlight = {
						enable = true,
						disable = function(lang, buf)
							local max_filesize = 150 * 1024 -- 150 KB
							local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
							if ok and stats and stats.size > max_filesize then
								return true
							end
						end,
					},
					indent = { enable = false },
					incremental_selection = {
						enable = true,
						keymaps = {
							init_selection = "<Enter>",
							node_incremental = "<Enter>",
							node_decremental = "<BS>",
						},
					},
					textobjects = {
						select = {
							enable = true,
							lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
							keymaps = {
								-- You can use the capture groups defined in textobjects.scm
                                -- This complements 'keymaps.ini_selection'
								["aa"] = "@parameter.outer",
								["ia"] = "@parameter.inner",
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["ac"] = "@class.outer",
								["ic"] = "@class.inner",
							},
						},
						move = {
							enable = true,
							set_jumps = true, -- whether to set jumps in the jumplist
							goto_next_start = {
								["]m"] = "@function.outer",
								["]]"] = "@class.outer",
							},
							goto_next_end = {
								["]M"] = "@function.outer",
								["]["] = "@class.outer",
							},
							goto_previous_start = {
								["[m"] = "@function.outer",
								["[["] = "@class.outer",
							},
							goto_previous_end = {
								["[M"] = "@function.outer",
								["[]"] = "@class.outer",
							},
						},
						swap = {
							enable = true,
							swap_next = {
								["<leader>a"] = "@parameter.inner",
							},
							swap_previous = {
								["<leader>A"] = "@parameter.inner",
							},
						},
					},
				})
			end, 0)
		end,
	},

	-- Show current AST-context on the top
	{
		"nvim-treesitter/nvim-treesitter-context",
        lazy = false,
        cmd = { "TSContextToggle" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        keys = {
            {
                "<leader>uC",
                ":TSContextToggle<cr>",
                desc = "Treesitter Context Toggle",
            },
        },
		init = function()
            -- TODO: update
			-- vim.cmd("highlight link TreesitterContext Comment")
			-- vim.cmd("highlight link TreesitterContextLineNumber Comment")
			-- vim.cmd("highlight link TreesitterContextSeparator Comment")
			-- vim.cmd("highlight link TreesitterContextBottom Comment")
		end,
        opts = {
            mode = "cursor",
            max_lines = 3
        },
	},

    -- Highlight current scope
    {
        "folke/twilight.nvim",
        cmd = { "Twilight" },
        keys = {
            {
                "<leader>ut",
                ":Twilight<cr>",
                desc = "Twilight Toggle",
            },
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        opts = {
            context = 15
        }
    },

	-- Add Hyprland Parser
	{
		"luckasRanarison/tree-sitter-hypr",
		enabled = function()
			return have("hypr")
		end,
		event = "BufRead */hypr/*.conf",
		build = ":TSUpdate hypr",
		config = function()
			-- Fix ft detection for hyprland
			vim.filetype.add({
				pattern = { [".*/hypr/.*%.conf"] = "hypr" },
			})
			require("nvim-treesitter.parsers").get_parser_configs().hypr = {
				install_info = {
					url = "https://github.com/luckasRanarison/tree-sitter-hypr",
					files = { "src/parser.c" },
					branch = "master",
				},
				filetype = "hypr",
			}
		end,
	},
}

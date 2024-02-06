local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.cmd([[colorscheme retrobox]])

require("ddob.options")
require("ddob.mappings")
require("ddob.autocmd")
require("ddob.usercmd")
require("ddob.highlights")

-- Load all plugins/*.lua
require("lazy").setup({
	spec = {
		{ import = "ddob.plugins" },
		{ import = "ddob.plugins.lsp" },
		{ import = "ddob.plugins.lang" },
	},
}, {
	defaults = { lazy = true },
	git = { timeout = 30 },
	install = { colorscheme = { "retrobox" } },
	ui = {
		size = { width = 0.9, height = 0.6 },
		border = "single",
		title = " Plugin Management ",
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	change_detection = {
		enabled = false,
		notify = false,
	},
})

if vim.g.neovide == true then
	-- padding
	vim.g.neovide_padding_top = 0
	vim.g.neovide_padding_bottom = 0
	vim.g.neovide_padding_right = 0
	vim.g.neovide_padding_left = 0
	-- floating shadow
	vim.g.neovide_floating_shadow = true
	vim.g.neovide_floating_z_height = 10
	vim.g.neovide_light_angle_degrees = 45
	vim.g.neovide_light_radius = 5
    -- scroll anim
    vim.g.neovide_scroll_animation_length = 0.3

    vim.g.neovide_unlink_border_highlights = true
    vim.g.neovide_cursor_vfx_mode = "pixiedust"

	vim.api.nvim_set_keymap(
		"n",
		"<C-+>",
		":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<C-->",
		":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>", { silent = true })
end

-- Reset Terminal Background color to curren ttheme
local handle = io.popen("tty")
local tty = handle:read("*a")
handle:close()

if tty:find("not a tty") then
	return
end

local reset = function()
	os.execute('printf "\\033]111\\007" > ' .. tty)
end

local update = function()
	local normal = vim.api.nvim_get_hl_by_name("Normal", true)
	local bg = normal["background"]
	local fg = normal["foreground"]
	if bg == nil then
		return reset()
	end

	local bghex = string.format("#%06x", bg)
	local fghex = string.format("#%06x", fg)

	if os.getenv("TMUX") then
		os.execute('printf "\\ePtmux;\\e\\033]11;' .. bghex .. '\\007\\e\\\\"')
		os.execute('printf "\\ePtmux;\\e\\033]12;' .. fghex .. '\\007\\e\\\\"')
	else
		os.execute('printf "\\033]11;' .. bghex .. '\\007" > ' .. tty)
		os.execute('printf "\\033]12;' .. fghex .. '\\007" > ' .. tty)
	end
end

local setup = function()
	vim.api.nvim_create_autocmd({ "ColorScheme", "UIEnter" }, { callback = update })
	vim.api.nvim_create_autocmd({ "VimLeavePre" }, { callback = reset })
end

setup()

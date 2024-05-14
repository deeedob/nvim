local opt = vim.opt
local g = vim.g

-- <space> as leader
g.mapleader = " "
g.maplocalleader = " "

-- Cursor
opt.cursorline = true
opt.cursorlineopt = "number"
opt.cursorcolumn = false
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver30-iCursor-blinkwait200-blinkon800,r-cr-o:hor20"

opt.inccommand = "split"

-- Pane splitting
opt.splitright = true
opt.splitbelow = true

-- Searching
opt.smartcase = true
opt.ignorecase = true
opt.hlsearch = false

-- Make terminal support truecolor
opt.termguicolors = true

-- maximum popup entries
opt.pumheight = 12

-- Make neovim use the system clipboard
opt.clipboard = "unnamedplus"

-- Disable old vim status
opt.showmode = false

-- Set relative line numbers
opt.number = true
opt.relativenumber = false
opt.numberwidth = 2

-- -- Tab config
opt.expandtab = true
opt.smartindent = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.shiftround = true
vim.cmd([[set cinoptions+=L0]])

-- Code folding
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "0"

-- Disable swapfile
opt.swapfile = false

-- Enable persistent undo
opt.undofile = true

-- Scrolloff
opt.scrolloff = 15
opt.sidescrolloff = 15

-- Disable wrapping
opt.wrap = false

-- Have the statusline only display at the bottom
opt.laststatus = 0
-- Hide the command line unless needed
-- TODO: ideally 0 but set to 2 to disable hit-enter msgs
opt.cmdheight = 2

-- Confirm to save changed before exiting the modified buffer
opt.confirm = true

-- Use ripgrep as the grep program for neovim
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- shortmess options
vim.opt.shortmess = vim.opt.shortmess
	+ {
		c = true, -- Do not show completion messages in command line
		F = true, -- Do not show file info when editing a file, in the command line
		W = true, -- Do not show "written" in command line when writing
		I = true, -- Do not show intro message when starting Vim
	}

-- Enable autowrite
opt.autowrite = true

-- <.<
opt.mouse = "a"

-- Keep cursor to the same screen line when opening a split
opt.splitkeep = "screen"

-- Set completion options
opt.completeopt = "menu,menuone,noselect"

-- Set key timeout to 300ms
opt.timeoutlen = 300

-- Window config
opt.winwidth = 5
opt.winminwidth = 5
opt.equalalways = false

-- Always show the signcolumn
opt.signcolumn = "auto:3"

-- Formatting options
opt.formatoptions = "jcroqlnt"

-- Put the cursor at the start of the line for large jumps
opt.startofline = false

-- Allow cursor to move where this is no text is visual block mode
opt.virtualedit = "block"

-- Command-line completion mode
opt.wildmode = "longest:full,full"

-- Session save options
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Maximum number of undo changes
opt.undolevels = 10000

-- Disable lsp logging
vim.lsp.set_log_level("OFF")

-- Disable certain builtins
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_netrwFileHandlers = 1
g.loaded_gzip = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_2html_plugin = 1
g.loaded_logipat = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_fzf = 1

-- Disable provider warnings in the healthcheck
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

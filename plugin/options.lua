local opt = vim.opt

vim.api.nvim_set_option_value('softtabstop', -1, {}) -- use shiftwidth
vim.api.nvim_set_option_value('shiftwidth', 0, {}) -- use tabstop
vim.api.nvim_set_option_value('tabstop', 4, {}) -- spaces per tab
vim.api.nvim_set_option_value('smartindent', true, {})
vim.api.nvim_set_option_value('expandtab', true, {})

-- Cursor
opt.cursorline = true
opt.cursorlineopt = "number"
opt.cursorcolumn = false

-- preview regex items
opt.inccommand = "split"

opt.signcolumn = "auto:3"

-- scrolloff
opt.scrolloff = 8
opt.sidescrolloff = 4

-- searching
opt.smartcase = true
opt.ignorecase = true

-- Diff
vim.opt.diffopt:append 'linematch:60'

-- numbers
opt.number = true
opt.relativenumber = false

opt.splitbelow = true
opt.splitright = true

-- TODO: find a way to disable numbers in foldcolumn
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', {})
vim.api.nvim_set_option_value('foldmethod', 'expr', {})
vim.api.nvim_set_option_value('foldtext', 'v:lua.NeatFoldText()', {})
vim.api.nvim_set_option_value("breakindent", true, {})
vim.api.nvim_set_option_value('linebreak', true, {})
-- vim.o.statuscolumn='%=%l%s%{foldlevel(v:lnum) > 0 ? (foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "-" : "+") : "│") : " " }'

opt.shada = { "'10", "<0", "s10", "h" }

opt.wrap = false

opt.clipboard = "unnamedplus"

opt.formatoptions:remove "o"

-- disable swapfile
opt.swapfile = false

-- Enable persistent undo
opt.undofile = true
opt.undolevels = 10000

-- Confirm to save changed before exiting the modified buffer
opt.confirm = true

-- Use ripgrep as the grep program for neovim
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

vim.opt.shortmess = vim.opt.shortmess + {
	A = true, -- When a swap file is found.
	C = true, -- When scanning for ins-completion items.
	F = true, -- File info when editing a file.
	I = true, -- Skip intro message.
	S = true, -- Search messages, using nvim-hlslens instead.
	W = false, -- When writing a file.
	a = true, -- Use abbreviations
	c = true, -- 'ins-completion-menu' messages.
	s = true, -- Search hit BOTTOM/TOP messages.
}

opt.complete = "" -- ".,t" How keyword completion works.
opt.completeopt = "menu,menuone,noinsert,preview" -- Disable native autocompletion (using nvim-cmp).
opt.pumblend = 5 -- Opaque completion menu background.
opt.pumheight = 5 -- Maximum height of popup menu.
opt.showmatch = false -- Do not jump to matching brackets.

-- Allow cursor to move where this is no text is visual block mode
opt.virtualedit = "block"

-- Enable autowrite
opt.autowrite = true

vim.lsp.set_log_level("OFF")
-- vim.lsp.log.set_format_func(vim.inspect) -- pretty print log

if _G['nvim >= 0.10'] then
	vim.api.nvim_set_option_value('smoothscroll', true, {})
end

-- <.<
opt.mouse = "a"

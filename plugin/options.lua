local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Cursor
opt.cursorline = true
opt.cursorlineopt = "number"
opt.cursorcolumn = false

-- preview regex items
opt.inccommand = "split"

opt.signcolumn = "auto"

-- scrolloff
opt.scrolloff = 8
opt.sidescrolloff = 4

-- searching
opt.smartcase = true
opt.ignorecase = true

-- numbers
opt.number = true
opt.relativenumber = false

opt.splitbelow = true
opt.splitright = true

vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

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
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  W = true, -- Do not show "written" in command line when writing
  I = true, -- Do not show intro message when starting Vim
}

-- Allow cursor to move where this is no text is visual block mode
opt.virtualedit = "block"

-- Enable autowrite
opt.autowrite = true

vim.lsp.set_log_level("OFF")

-- <.<
opt.mouse = "a"

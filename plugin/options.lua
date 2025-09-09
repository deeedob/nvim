-- >> Behavior & Editor Functionality
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.hidden = true
vim.opt.confirm = true
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.virtualedit = "block"
vim.opt.joinspaces = false
vim.opt.inccommand = "split"
vim.opt.cpoptions = "aAceFs_B"
vim.opt.mouse = "a"
vim.opt.guicursor = "n-v-c-sm:block-Cursor,"
  .. "i-ci-ve:ver30-blinkwait200-blinkon800,"
  .. "r-cr-o:hor20"
vim.opt.smoothscroll = true

-- >> UI & Appearance
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.signcolumn = "auto:3"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 4
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.laststatus = 3
vim.opt.visualbell = true
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.opt.title = true
vim.opt.titlestring = "%t (%f)"

vim.opt.complete = "" -- ".,t" How keyword completion works.
vim.opt.completeopt = "menu,menuone,noinsert,preview"
vim.opt.pumblend = 5 -- Opaque completion menu background.
vim.opt.pumheight = 5 -- Maximum height of popup menu.
vim.opt.showmatch = false -- Do not jump to matching brackets.

-- >> Windows, Splits & Diff
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.diffopt:append({
  "vertical",
  "iwhiteall",
  "iwhiteeol",
  "indent-heuristic",
  "hiddenoff",
  "closeoff",
  "algorithm:patience",
  "linematch:100",
})

-- >> Indentation & Tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.smartindent = true
vim.opt.copyindent = true
vim.opt.shiftround = true

-- >> Text & Line Breaking
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.formatoptions:remove "o"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldtext = "v:lua.NeatFoldText()"

-- >> Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
if vim.bo.modifiable then
    vim.opt.fileencoding = 'utf-8'
end
vim.opt.shada = { "!", "/1000", "'1000", "<1000", ":1000", "s10000", "h" }
if jit.os == "windows" then
  vim.opt.shada:append({ "rA:", "rB:", "rC:", "rC:/Temp" })
else
  vim.opt.shada:append("r/tmp/")
end
vim.opt.shortmess:append({ A = true, C = true, F = true, I = true, s = true, a = true })

local words_path = "/usr/share/dict/words"
if vim.uv.fs_stat(words_path) then
  vim.opt.dictionary:append(words_path)
end

-- >> Files & Grep
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- >> Diagnostic
vim.diagnostic.config {
  underline = true,
  virtual_text = false,
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ColumnDiagnosticError",
      [vim.diagnostic.severity.WARN] = "ColumnDiagnosticWarn",
      [vim.diagnostic.severity.INFO] = "ColumnDiagnosticInfo",
      [vim.diagnostic.severity.HINT] = "ColumnDiagnosticHint",
    },
  },
  update_in_insert = true,
  severity_sort = true,
  float = {
    scope = "line",
    border = "rounded",
    header = "",
    prefix = " ",
    focusable = false,
    source = true,
  },
}

local wildignores = {
  "*.spl",
  "*.aux",
  "*.out",
  "*.o",
  "*.pyc",
  "*.gz",
  "*.sw",
  "*.swp",
  "*.swap",
  "*.com",
  "*.class",
  "*.slo",
  "*.lo",
  "*.oarma72smp",
  "*.oppc500",
  "*.oppc",
  "*.opp",
  "*.so",
  "*.lai",
  "*.la",
  "*.a",
  "*.pkl",
  "*cache/*",
  "*__pycache__/*",
}

local no_backup = {
  ".git/*",
  ".clangd/*",
  ".gem/*",
  ".caddir/",
  ".svn/*",
  "*.bin",
  "*.7z",
  "*.dmg",
  "*.gz",
  "*.iso",
  "*.jar",
  "*.rar",
  "*.tar",
  "*.zip",
  "*.exe",
  "TAGS",
  "tags",
  "GTAGS",
  "COMMIT_EDITMSG",
}
vim.opt.wildignore = wildignores
vim.opt.backupskip = vim.list_extend(no_backup, wildignores)

-- >> Globals for Specific Filetypes/Plugins
vim.g.c_syntax_for_h = 0
vim.g.c_comment_strings = 1
vim.g.c_no_if0 = 0
vim.g.terminal_scrollback_buffer_size = 100000

-- >> Disabled Built-in Plugins
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0

vim.g.loaded_2html_plugin = 0
vim.g.loaded_getscript = 0
vim.g.loaded_getscriptPlugin = 0
vim.g.loaded_gzip = 0
vim.g.loaded_matchit = 0
vim.g.loaded_matchparen = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_rrhelper = 0
vim.g.loaded_tar = 0
vim.g.loaded_tarPlugin = 0
vim.g.loaded_tutor_mode_plugin = 0
vim.g.loaded_vimball = 0
vim.g.loaded_vimballPlugin = 0
vim.g.loaded_zip = 0
vim.g.loaded_zipPlugin = 0

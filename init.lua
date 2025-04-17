if vim.loader then
  vim.loader.enable() -- reduced startup time
end

vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<space>")

vim.o.termguicolors = true
vim.o.guicursor = "n-v-c-sm:block-Cursor,"
  .. "i-ci-ve:ver30-blinkwait200-blinkon800,"
  .. "r-cr-o:hor20"
-- .. "a:Cursor"

vim.api.nvim_command "colorscheme ddob-kanagawa"

-- Setup Lazy.nvim and load all plugins
require("shared.lazy")
-- Finished loading all plugins

-- Setup neovim LSP
local lsp_configs = {}
for _, f in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local server_name = vim.fn.fnamemodify(f, ":t:r")
  table.insert(lsp_configs, server_name)
end
vim.lsp.enable(lsp_configs)

-- Post init setup
require("shared.utils").resetTerminalBg()
vim.cmd([[
    if has('nvim')
        " make sure that GIT_EDITOR is not set before here
        let $GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
    endif
]])

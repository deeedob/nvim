-- Enable the new Lua module loader for faster startup
vim.loader.enable()

-- Enforce minimum Neovim version
if vim.version.lt(vim.version(), { 0, 12 }) then
  vim.api.nvim_echo({ { "Neovim >= 0.12 is required. Please update.", "ErrorMsg" } }, true, {})
  return
end

-- Leader must be set before any plugins or keymaps are loaded
vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<space>")

-- Flag used by plugin specs to skip loading plugins in headless sessions
vim.g.has_ui = #vim.api.nvim_list_uis() > 0

vim.cmd.colorscheme("ddob-kanagawa")

-- Bootstrap lazy.nvim and load all plugin specs (only when a UI is present)
if vim.g.has_ui then
  require("utils.plugin").setup()
end

require("lsp").setup()

-- Use nvr as $GIT_EDITOR so git commit/rebase buffers open inside Neovim
if vim.fn.executable("nvr") == 1 then
  vim.env.GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
end

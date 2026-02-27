-- Enable the new Lua module loader for faster startup
vim.loader.enable()

-- Enforce minimum Neovim version
if vim.version.lt(vim.version(), { 0, 11 }) then
  vim.api.nvim_echo({ { "Neovim >= 0.11 is required. Please update.", "ErrorMsg" } }, true, {})
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

-- Optional LSP debug logging
if vim.env.NVIM_LSP_DEBUG then
  vim.lsp.set_log_level(vim.log.levels.DEBUG)
  vim.notify("LSP logging: DEBUG\n" .. vim.lsp.get_log_path())
end

-- Apply shared capabilities to every LSP server config before enabling them.
-- Individual lsp/*.lua files may still declare additional capabilities.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local lsp_configs = {}
for _, f in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local name = vim.fn.fnamemodify(f, ":t:r")
  table.insert(lsp_configs, name)
  vim.lsp.config(name, { capabilities = capabilities })
end
vim.lsp.enable(lsp_configs)

-- Use nvr as $GIT_EDITOR so git commit/rebase buffers open inside Neovim
if vim.fn.executable("nvr") == 1 then
  vim.env.GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
end

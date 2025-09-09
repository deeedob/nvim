if vim.loader then
  vim.loader.enable() -- reduced startup time
end

if vim.version.lt(vim.version(), { 0, 11 }) then
  vim.api.nvim_echo({ "Neovim version is too old! Please update it." }, true, {
    err = true,
  })
end

vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<space>")
vim.g.has_ui = #vim.api.nvim_list_uis() > 0

vim.api.nvim_command "colorscheme ddob-kanagawa"

if vim.g.has_ui then
    require("utils.plugin").setup("ddob/plugins")
end

-- Setup neovim LSP
vim.lsp.log.set_level(vim.o.verbose > 0 and vim.log.levels.INFO or vim.log.levels.WARN)

local lsp_configs = {}
for _, f in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
  local server_name = vim.fn.fnamemodify(f, ":t:r")
  table.insert(lsp_configs, server_name)
end
vim.lsp.enable(lsp_configs)


-- Post init setup
-- require("shared.utils").resetTerminalBg()
vim.cmd([[
    if has('nvim')
        " make sure that GIT_EDITOR is not set before here
        let $GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
    endif
]])

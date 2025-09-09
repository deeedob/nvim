-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/jsonls.lua

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = {
    provideFormatter = true,
  },
	root_markers = { ".git" },
  single_file_support = true,
  -- https://raw.githubusercontent.com/microsoft/vscode/master/extensions/json-language-features/package.json
  settings = function()
    local schemas
    if pcall(require, "schemastore") then
      schemas = require("schemastore").json.schemas()
    end
    return {
      json = {
        schemas = schemas,
        validate = { enable = true },
      }
    }
  end
}


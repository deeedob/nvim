-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/jsonls.lua

return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { ".git" },
  single_file_support = true,
  -- Inject schemastore schemas after the server starts, when plugins are ready.
  on_new_config = function(config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      })
    end
  end,
}

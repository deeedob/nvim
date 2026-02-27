-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/yamlls.lua

return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = {
    "yaml",
    "yaml.docker-compose",
    "yaml.gitlab",
  },
  root_markers = { ".git" },
  single_file_support = true,
  -- Inject schemastore schemas after the server starts, when plugins are ready.
  on_new_config = function(config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = schemastore.yaml.schemas(),
        },
        redhat = { telemetry = { enabled = false } },
      })
    end
  end,
}

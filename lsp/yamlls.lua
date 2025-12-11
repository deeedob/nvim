-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/yamlls.lua

return {
  cmd = {
    "yaml-language-server",
    "--stdio",
  },
  filetypes = {
    "yaml",
    "yaml.docker-compose",
    "yaml.gitlab",
  },
  root_markers = { ".git" },
  single_file_support = true,
  -- https://raw.githubusercontent.com/redhat-developer/vscode-yaml/master/package.json
  settings = {
    yaml = {
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
  },
}

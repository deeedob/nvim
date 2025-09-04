-- lsp/tsserver.lua
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  root_markers = { "package.json", ".git" },
  single_file_support = true,
  on_attach = function(client)
    -- this is important, otherwise tsserver will format ts/js
    -- files which we *really* don't want.
    client.server_capabilities.documentFormattingProvider = false
  end,
}

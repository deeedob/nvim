-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/buf_ls.lua

return {
  cmd = { "buf", "beta", "lsp", "--timeout=0", "--log-format=text" },
  root_markers = { ".git", "buf.yaml" },
  filetypes = { "proto" },
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/taplo.lua

return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
	root_markers = { ".marksman.toml", ".git" },
  single_file_support = true,
}

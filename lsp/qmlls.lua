-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/qmlls.lua

return {
  cmd = { "qmlls" },
  filetypes = { "qml", "qmljs" },
  root_markers = { ".qmlls.ini" },
  single_file_support = true,
}

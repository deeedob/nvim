-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/neocmake.lua

return {
  cmd = { "neocmakelsp", "stdio" },
  filetypes = { "cmake" },
  root_markers = { ".git", "build", "cmake", "cmake-build" },
  workspace_required = false,
  single_file_support = true,
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
        relative_pattern_support = true,
      },
    },
  },
  init_options = {
    format = { enable = true },
    lint = { enable = true },
    scan_cmake_in_package = true,
  },
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/neocmake.lua

return {
    cmd = { "neocmakelsp", "--stdio" },
    filetypes = { "cmake" },
    root_markers = { ".git", "build", "cmake", "cmake-build" },
    single_file_support = true,
}

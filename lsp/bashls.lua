-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/bashls.lua

return {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "sh" },
    root_markers = { ".git" },
    single_file_support = true,
    settings = {
      bashIde = {
        -- Glob pattern for finding and parsing shell script files in the workspace.
        globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
      }
    }
}

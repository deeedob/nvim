-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/glsl_analyzer.lua

return {
    cmd = { 'glsl_analyzer' },
    filetypes = { 'glsl', 'vert', 'tesc', 'tese', 'frag', 'geom', 'comp' },
	  root_markers = { ".git" },
    single_file_support = true,
    capabilities = {},
}

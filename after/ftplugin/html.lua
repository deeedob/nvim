vim.api.nvim_set_option_value("tabstop", 2, {})

vim.cmd [[autocmd! BufRead,BufNewFile *.html  call jinja#AdjustFiletype()]]

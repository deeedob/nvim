local M = {}

function M.search_current_web(url)
    local current_word = vim.fn.expand("<cword>")
    local escaped_word = vim.fn.fnameescape(current_word)
    local link = string.format(url .. "%s", escaped_word)
    print(link)
    vim.fn.jobstart({ "xdg-open", link }, { detach = true })
end

function M.get_visual_pos()
    local _, brow, bcol = unpack(vim.fn.getpos('v'))
    local _, erow, ecol = unpack(vim.fn.getpos('.'))
    return { brow, bcol }, { erow, ecol }
end

function M.get_visual_text()
    local b, e = M.get_visual_pos()
    return vim.api.nvim_buf_get_text(0, b[1] - 1, b[2] - 1, e[1] - 1, e[2], {})
end

return M

local M = {}

function M.search_current_web(url_template)
  local current_word = vim.fn.expand "<cword>"
  if not current_word or current_word == "" then
    vim.notify("No word under cursor.", vim.log.levels.WARN)
    return
  end
  local escaped_word = string.gsub(current_word, " ", "+")
  local link = string.format(url_template, escaped_word)
  vim.notify("Opening: " .. link, vim.log.levels.INFO)
  vim.ui.open(link)
end

function M.resetTerminalBg()
  -- Reset Terminal Background color to current ttheme
  local handle = io.popen "tty"
  local tty = handle:read "*a"
  handle:close()

  if tty:find "not a tty" then
    return
  end

  local reset = function()
    os.execute('printf "\\033]111\\007" > ' .. tty)
  end

  local update = function()
    local normal = vim.api.nvim_get_hl_by_name("Normal", true)
    local bg = normal["background"]
    local fg = normal["foreground"]
    if bg == nil then
      return reset()
    end

    local bghex = string.format("#%06x", bg)
    local fghex = string.format("#%06x", fg)

    if os.getenv "TMUX" then
      os.execute('printf "\\ePtmux;\\e\\033]11;' .. bghex .. '\\007\\e\\\\"')
      os.execute('printf "\\ePtmux;\\e\\033]12;' .. fghex .. '\\007\\e\\\\"')
    else
      os.execute('printf "\\033]11;' .. bghex .. '\\007" > ' .. tty)
      os.execute('printf "\\033]12;' .. fghex .. '\\007" > ' .. tty)
    end
  end

  local setup = function()
    vim.api.nvim_create_autocmd(
      { "ColorScheme", "UIEnter" },
      { callback = update }
    )
    vim.api.nvim_create_autocmd({ "VimLeavePre" }, { callback = reset })
  end

  setup()
  local b, e = M.get_visual_pos()
  return vim.api.nvim_buf_get_text(0, b[1] - 1, b[2] - 1, e[1] - 1, e[2], {})
end

---@param entry cmp.Entry
function M.auto_brackets(entry)
  local cmp = require "cmp"
  local Kind = cmp.lsp.CompletionItemKind
  local item = entry:get_completion_item()
  if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local prev_char = vim.api.nvim_buf_get_text(
      0,
      cursor[1] - 1,
      cursor[2],
      cursor[1] - 1,
      cursor[2] + 1,
      {}
    )[1]
    if prev_char ~= "(" and prev_char ~= ")" then
      local keys =
        vim.api.nvim_replace_termcodes("()<left>", false, false, true)
      vim.api.nvim_feedkeys(keys, "i", true)
    end
  end
end

function M.find_project_root()
  local root = vim.fs.find(
    { ".git", "CMakePresets.json", "requirements.txt" },
    { upward = true }
  )
  if root and #root > 0 then
    return vim.fn.fnamemodify(root[1], ":h")
  end
  return nil
end

return M

local M = {}

--- Open a web search for the word under the cursor.
--- @param url_template string  A format string with a single `%s` placeholder
---                             that will be replaced by the (URL-encoded) word.
function M.search_current_web(url_template)
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    vim.notify("No word under cursor.", vim.log.levels.WARN)
    return
  end
  local encoded = word:gsub(" ", "+")
  local url = url_template:format(encoded)
  vim.notify("Opening: " .. url, vim.log.levels.INFO)
  vim.ui.open(url)
end

--- Reset the terminal emulator's background/foreground colours to match the
--- current Neovim colorscheme via OSC escape sequences.
--- Registers ColorScheme / UIEnter / VimLeavePre autocmds once called.
function M.resetTerminalBg()
  local handle = io.popen("tty")
  if not handle then
    return
  end
  local tty = handle:read("*a")
  handle:close()

  if not tty or tty:find("not a tty") then
    return
  end
  tty = tty:gsub("%s+$", "") -- trim trailing newline

  local function reset()
    os.execute('printf "\\033]111\\007" > ' .. tty)
  end

  local function update()
    -- nvim_get_hl supersedes the deprecated nvim_get_hl_by_name
    local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local bg = hl.bg
    local fg = hl.fg
    if bg == nil then
      reset()
      return
    end
    local bghex = ("#%06x"):format(bg)
    local fghex = ("#%06x"):format(fg or 0xffffff)

    if os.getenv("TMUX") then
      os.execute('printf "\\ePtmux;\\e\\033]11;' .. bghex .. '\\007\\e\\\\"')
      os.execute('printf "\\ePtmux;\\e\\033]12;' .. fghex .. '\\007\\e\\\\"')
    else
      os.execute('printf "\\033]11;' .. bghex .. '\\007" > ' .. tty)
      os.execute('printf "\\033]12;' .. fghex .. '\\007" > ' .. tty)
    end
  end

  local grp = vim.api.nvim_create_augroup("ddob/terminal-bg", { clear = true })
  vim.api.nvim_create_autocmd({ "ColorScheme", "UIEnter" }, { group = grp, callback = update })
  vim.api.nvim_create_autocmd({ "VimLeavePre" }, { group = grp, callback = reset })
  update() -- apply immediately
end

--- Walk upward from the current file to find the project root.
--- Recognises .git, CMakePresets.json, and requirements.txt.
---@return string|nil
function M.find_project_root()
  local markers = vim.fs.find(
    { ".git", "CMakePresets.json", "requirements.txt" },
    { upward = true }
  )
  if markers and #markers > 0 then
    return vim.fn.fnamemodify(markers[1], ":h")
  end
  return nil
end

return M

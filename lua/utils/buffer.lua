local M = {}

function M.get_visual_pos()
  local _, brow, bcol = unpack(vim.fn.getpos("v"))
  local _, erow, ecol = unpack(vim.fn.getpos("."))
  return { brow, bcol }, { erow, ecol }
end

function M.get_cursor_pos()
  local pos = vim.fn.getpos(".")
  return { pos[2], pos[3] }
end

function M.get_visual_text()
  local b, e = M.get_visual_pos()
  return vim.api.nvim_buf_get_text(0, b[1] - 1, b[2] - 1, e[1] - 1, e[2], {})
end

--- Returns the absolute path of the current buffer if it is a readable file,
--- otherwise notifies and returns nil.
function M.current_file()
  local p = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
  if p == "" or vim.fn.filereadable(p) == 0 then
    vim.notify("Buffer is not a readable file", vim.log.levels.WARN)
    return nil
  end
  return p
end

--- Resolves a file token (path, path:line, path:line:col) from the text under
--- the cursor. Returns { path, lnum, cnum } or nil if nothing is found.
function M.resolve_file_under_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  col = col + 1 -- nvim_win_get_cursor columns are 0-indexed
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

  -- Expand a non-whitespace token centered on the cursor
  local start_pos = col
  while start_pos > 1 and line:sub(start_pos - 1, start_pos - 1):match("[^%s]") do
    start_pos = start_pos - 1
  end
  local end_pos = col
  while end_pos <= #line and line:sub(end_pos, end_pos):match("[^%s]") do
    end_pos = end_pos + 1
  end

  local token = line:sub(start_pos, end_pos - 1)
  local path, lnum, cnum

  path, lnum, cnum = token:match("^(.+):(%d+):(%d+)")
  if not path then
    path, lnum = token:match("^(.+):(%d+)")
  end
  if not path then
    path = token ~= "" and token or nil
  end
  if not path then
    return nil
  end

  path = vim.fn.expand(path)

  if not vim.startswith(path, "/") then
    local dir = vim.fn.expand("%:p:h")
    local found = false
    for _, candidate in ipairs({ path, dir .. "/" .. path }) do
      if vim.fn.filereadable(candidate) == 1 then
        path = candidate
        found = true
        break
      end
    end
    if not found then
      vim.notify("File not found: " .. path, vim.log.levels.WARN)
      return nil
    end
  elseif vim.fn.filereadable(path) == 0 then
    vim.notify("File not readable: " .. path, vim.log.levels.WARN)
    return nil
  end

  return { path = path, lnum = lnum and tonumber(lnum), cnum = cnum and tonumber(cnum) }
end

--- Opens the current file's containing folder in the system file explorer.
function M.open_in_file_explorer()
  local path = M.current_file()
  if not path then
    return
  end

  if vim.fn.has("macunix") == 1 then
    vim.system({ "open", "-R", path }, { detach = true })
    return
  end

  local uri = vim.uri_from_fname(path)
  vim.system({
    "dbus-send",
    "--session",
    "--print-reply",
    "--dest=org.freedesktop.FileManager1",
    "/org/freedesktop/FileManager1",
    "org.freedesktop.FileManager1.ShowItems",
    "array:string:" .. uri,
    "string:",
  }, {}, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.system({ "xdg-open", vim.fn.fnamemodify(path, ":h") }, { detach = true })
      end)
    end
  end)
end

--- Copies the current file (as a file object, not its path) to the system clipboard.
--- Falls back to yanking the path as text if no clipboard tool is found.
function M.copy_file_to_clipboard()
  local path = M.current_file()
  if not path then
    return
  end

  if vim.fn.has("macunix") == 1 then
    vim.system({
      "osascript",
      "-e",
      ('set the clipboard to (POSIX file "%s")'):format(path:gsub('"', '\\"')),
    })
    vim.notify("Copied file to clipboard")
    return
  end

  local uri = vim.uri_from_fname(path)

  if vim.fn.executable("wl-copy") == 1 then
    vim.system({ "wl-copy", "--type", "text/uri-list" }, { stdin = uri .. "\n" }, function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify("Copied file to clipboard")
        else
          vim.notify("wl-copy failed", vim.log.levels.WARN)
        end
      end)
    end)
    return
  end

  if vim.fn.executable("xclip") == 1 then
    vim.system(
      { "xclip", "-selection", "clipboard", "-t", "text/uri-list" },
      { stdin = uri .. "\n" },
      function(res)
        vim.schedule(function()
          if res.code == 0 then
            vim.notify("Copied file to clipboard")
          else
            vim.notify("xclip failed", vim.log.levels.WARN)
          end
        end)
      end
    )
    return
  end

  -- Fallback: yank the path as plain text
  vim.fn.setreg("+", path)
  vim.notify("Copied path to clipboard (no wl-copy/xclip found)", vim.log.levels.WARN)
end

--- Jumps to the file under the cursor, supporting path:line:col notation.
--- If called from a terminal buffer, switches to the previous window first.
function M.goto_file_under_cursor()
  local target = M.resolve_file_under_cursor()
  if not target then
    vim.notify("No file path found under cursor", vim.log.levels.WARN)
    return
  end

  if vim.bo[vim.api.nvim_win_get_buf(0)].buftype == "terminal" then
    vim.cmd.wincmd("p")
  end

  vim.cmd.edit(vim.fn.fnameescape(target.path))

  if target.lnum then
    local line_num = math.min(target.lnum, vim.api.nvim_buf_line_count(0))
    local col_num = target.cnum and (target.cnum - 1) or 0
    vim.api.nvim_win_set_cursor(0, { line_num, col_num })
    vim.cmd("normal! zz")
  end
end

-- ── Diagnostics ───────────────────────────────────────────────────────────────

--- Opens a floating diagnostic window for the given scope ("cursor" or "line").
function M.diag_open(scope)
  vim.diagnostic.open_float(nil, {
    scope = scope or "cursor",
    focusable = true,
    focus_id = "diagnostic_float",
    source = "if_many",
    close_events = { "CursorMoved", "CursorMovedI", "InsertEnter" },
  })
end

--- Jumps to the next/previous diagnostic and opens a float for it.
--- @param count number  positive = forward, negative = backward
function M.diag_jump(count)
  local jumped = vim.diagnostic.jump({ count = count, wrap = true })
  if jumped then
    vim.schedule(function()
      M.diag_open("cursor")
    end)
  end
end

return M

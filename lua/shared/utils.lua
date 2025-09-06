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

function M.get_visual_pos()
  local _, brow, bcol = unpack(vim.fn.getpos "v")
  local _, erow, ecol = unpack(vim.fn.getpos ".")
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

function M.change_width(d)
  local v = vim.api

  -- Lua version of a ternery operator
  d = d and d or "left"

  local lr = d == "left" or d == "right"
  -- 5 for left right, 3 for up downgit branch -a --contains <commit>
  local amt = lr and 5 or 3

  local pos = v.nvim_win_get_position(0)
  local w = v.nvim_win_get_width(0)
  local h = v.nvim_win_get_height(0)

  if lr then
    amt = pos[2] == 0 and -amt or amt
  else
    amt = pos[1] == 0 and -amt or amt
  end

  w = (d == "left") and (w + amt) or (w - amt)
  h = (d == "up") and (h + amt) or (h - amt)

  if lr then
    v.nvim_win_set_width(0, w)
  else
    v.nvim_win_set_height(0, h)
  end
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

function M.git_branches_for_code()
  local commit = nil
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- If in visual mode, get the visual text snippet.
    local snippet_lines = M.get_visual_text()
    local snippet = table.concat(snippet_lines, "\n")
    if snippet == "" then
      print("No snippet selected!")
      return
    end
    -- Use git log -S to find the earliest commit introducing the snippet.
    local log_cmd = "git log -S" .. vim.fn.shellescape(snippet)
      .. " --pretty=format:'%H' --reverse | head -n1"
    commit = vim.fn.system(log_cmd):gsub("%s+", "")
    if commit == "" then
      print("Snippet not found in history!")
      return
    end
  else
    -- If not in visual mode, fall back to using the current line.
    local filepath = vim.fn.expand "%:p"
    if not filepath or filepath == "" then
      print("No file found!")
      return
    end
    local pos = M.get_cursor_pos()  -- { line, col }
    local line = pos[1]
    local blame_cmd = "git blame -L " .. line .. "," .. line
      .. " --porcelain " .. vim.fn.shellescape(filepath)
    local blame_output = vim.fn.systemlist(blame_cmd)
    if vim.v.shell_error ~= 0 or #blame_output == 0 then
      print("Could not retrieve blame info")
      return
    end
    commit = blame_output[1]:match("^(%w+)")
    if not commit then
      print("Could not parse commit hash")
      return
    end
  end

  -- Now get branches containing this commit.
  local branch_cmd = "git branch -a --contains " .. commit
  local branches = vim.fn.systemlist(branch_cmd)
  if vim.v.shell_error ~= 0 or #branches == 0 then
    print("No branches found for commit " .. commit)
    return
  end

  -- Clean up branch names: trim spaces and remove any leading '*'
  for i, branch in ipairs(branches) do
    branch = branch:gsub("^%s*", ""):gsub("%s*$", ""):gsub("^%*", "")
    branches[i] = branch
  end

  -- Use Telescope to display the branches
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  pickers.new({}, {
    prompt_title = "Branches for commit " .. commit,
    finder = finders.new_table { results = branches },
    sorter = conf.generic_sorter {},
  }):find()
end

function M.git_revise_current_word()
  local commit = vim.fn.expand("<cword>")
  -- Check if commit looks like a valid hexadecimal hash (at least 7 characters)
  if commit:match("^[0-9a-fA-F]+$") and #commit >= 7 then
    local cmd = "git revise -e " .. commit
    vim.cmd("TermExec cmd='" .. cmd .. "'")
  else
    print("Not a valid commit hash: " .. commit)
  end
end

return M

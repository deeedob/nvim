local M = {}

function M.branches_for_code()
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

function M.revise_current_word()
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

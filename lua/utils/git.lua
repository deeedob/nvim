local M = {}

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

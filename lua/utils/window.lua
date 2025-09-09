local M = {}

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

return M

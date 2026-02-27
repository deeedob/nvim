local M = {}

--- Resize the current window in a directional way, adjusting by a fixed step.
--- The sign of the step is automatically flipped for windows that are on the
--- left/top edge so that the perceived direction is always consistent.
---@param d "left"|"right"|"up"|"down"
function M.change_width(d)
  d = d or "left"
  local is_lr = d == "left" or d == "right"
  -- 5 columns for left/right, 3 rows for up/down
  local amt = is_lr and 5 or 3

  local pos = vim.api.nvim_win_get_position(0)

  if is_lr then
    -- Flip sign for windows on the left edge so "grow left" still grows
    amt = pos[2] == 0 and -amt or amt
    local w = vim.api.nvim_win_get_width(0)
    w = (d == "left") and (w + amt) or (w - amt)
    vim.api.nvim_win_set_width(0, w)
  else
    -- Flip sign for windows on the top edge
    amt = pos[1] == 0 and -amt or amt
    local h = vim.api.nvim_win_get_height(0)
    h = (d == "up") and (h + amt) or (h - amt)
    vim.api.nvim_win_set_height(0, h)
  end
end

return M

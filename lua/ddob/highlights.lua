local fmt = string.format

local function to_rgb(color)
	return tonumber(color:sub(2, 3), 16), tonumber(color:sub(4, 5), 16), tonumber(color:sub(6), 16)
end

local function clamp_color(color)
	return math.max(math.min(color, 255), 0)
end

local M = {}

-- https://stackoverflow.com/a/13532993
function M.brighten(color, percent)
	local r, g, b = to_rgb(color)
	r = clamp_color(math.floor(tonumber(r * (100 + percent) / 100)))
	g = clamp_color(math.floor(tonumber(g * (100 + percent) / 100)))
	b = clamp_color(math.floor(tonumber(b * (100 + percent) / 100)))
	return "#" .. fmt("%0x", r) .. fmt("%0x", g) .. fmt("%0x", b)
end

function M.highlight(group, color)
	local style = color.style and "gui=" .. color.style or "gui=NONE"
	local fg = color.fg and "guifg=" .. color.fg or "guifg=NONE"
	local bg = color.bg and "guibg=" .. color.bg or "guibg=NONE"
	local sp = color.sp and "guisp=" .. color.sp or ""
	local hl = "highlight " .. group .. " " .. style .. " " .. fg .. " " .. bg .. " " .. sp
	vim.cmd(hl)
end

local tabline = vim.api.nvim_get_hl(0, { name = "TabLine" })
local tabline_fill = vim.api.nvim_get_hl(0, { name = "TabLineFill" })

local active = {
	bg = tabline.bg,
	fg = tabline_fill.fg,
}

local inactive = {
	bg = tabline.bg,
	fg = tabline.fg,
}

vim.api.nvim_set_hl(0, "NeoTreeTabInactive", inactive)
vim.api.nvim_set_hl(0, "NeoTreeTabActive", active)
vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", inactive)
vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", active)


-- vim.api.nvim_set_hl(0, "WindowPickerStatusLine", inactive)
-- vim.api.nvim_set_hl(0, "WindowPickerStatusLineNC", inactive)
-- vim.api.nvim_set_hl(0, "WindowPickerWinBar", inactive)
-- vim.api.nvim_set_hl(0, "WindowPickerWinBarNC", inactive)
-- M.highlight("WindowPickerStatusLine", { fg="#ff00ff", bg="#ff0000"})
-- M.highlight("WindowPickerStatusLineNC", { fg="#ff00ff", bg="#ff0000"})
-- M.highlight("WindowPickerWinBar", { fg="#ff00ff", bg="#ff0000"})
-- M.highlight("WindowPickerWinBarNC", { fg="#ff00ff", bg="#ff0000"})

return M

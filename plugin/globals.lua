-- Print inspected @v
P = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

-- Reload @mod from table
R = function(mod)
  RELOAD(mod)
  return require(mod)
end

-- Show the table for @mod
S = function(mod)
  P(package.loaded[mod])
end

-- Thank @iron-e
function Bench(fn, loops)
  loops = loops or 100000

  local now = vim.loop.hrtime --- @type fun(): integer
  local total = 0

  for i = 1, loops do
    local start = now()
    fn(i)
    total = total + (now() - start)
  end

  print(total / loops)
end

function NeatFoldText()
	local end_ = vim.v.foldend --- @type number
	local start = vim.v.foldstart --- @type number

	local lines = { start, end_ }
	for i, line_nr in ipairs(lines) do
		local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, true)[1]
		lines[i] = line
	end

	--- @cast lines string[]

	do
		local columns = vim.api.nvim_win_get_width(0)
		local first_line = lines[1]
		local first_line_len = #first_line

		-- NOTE: 10 is the magic number for the base width of the template line.
		--       5 is a heuristic because linenr/sign column width is indeterminable
		--       3 is the magic number for joining the lines
		local needed_width = #lines[2] + 10 + 5 + 3

		if first_line_len + needed_width > columns then
			local overflow = math.abs(first_line_len - columns)

			-- NOTE: 5 is the magic number for the replacement len.
			local remove = math.ceil(bit.rshift(overflow, 1) + needed_width + 5)
			local middle = bit.rshift(first_line_len, 1)

			lines[1] = first_line:sub(1, middle - remove) .. ' […] ' .. first_line:sub(middle + remove)
		end
	end

	return ('   %-6d%s'):format(end_ - start + 1, table.concat(lines, ' … '))
end

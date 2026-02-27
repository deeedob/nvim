-- Global development helpers available in every Lua context.
-- These are intentionally placed in _G for interactive/REPL use.
-- Do NOT use these in production code paths — use proper requires instead.

--- Reload a Lua module, invalidating both package.loaded and the Neovim
--- bytecode cache so live changes take effect without restarting.
---@param modname string
---@return unknown
_G.RELOAD = function(modname)
  package.loaded[modname] = nil
  if vim.loader then
    vim.loader.reset(modname)
  end
  return require(modname)
end

--- Pretty-print any number of values using vim.inspect and return them
--- unchanged, so the function is safe to use inside expressions.
---@param ... any
---@return ...
_G.P = function(...)
  local args = { ... }
  print(table.unpack(vim.tbl_map(vim.inspect, args)))
  return ...
end

_G.PRINT = _G.P

--- Paste arbitrary data (string / table / any) into the current buffer at the
--- cursor position, similar to a register paste.
---@param data any
_G.PASTE = function(data)
  local lines
  if vim.isarray(data) then
    lines = vim.deepcopy(data)
  elseif type(data) == "string" then
    lines = vim.split(data, "\n")
  else
    lines = vim.split(vim.inspect(data), "\n")
  end
  vim.paste(
    vim.tbl_map(function(v)
      return type(v) == "string" and v or vim.inspect(v)
    end, lines),
    -1
  )
end

--- Measure the wall-clock time (seconds) of a function call and print it.
---@param msg string|nil  Label printed before the elapsed time
---@param fn function     Function to benchmark
---@param ... any         Arguments forwarded to fn
---@return any            Return value(s) of fn
_G.PERF = function(msg, fn, ...)
  assert(type(fn) == "function", "PERF: second argument must be a function")
  assert(msg == nil or type(msg) == "string", "PERF: first argument must be a string or nil")
  msg = msg or "Elapsed:"
  local start = os.clock()
  local result = fn(...)
  print(msg, ("%.4f s"):format(os.clock() - start))
  return result
end

--- Custom foldtext: shows the line count and truncates long first lines so the
--- fold summary always fits in the current window width.
--- Referenced by vim.opt.foldtext = "v:lua.NeatFoldText()" in plugin/options.lua.
_G.NeatFoldText = function()
  local fold_start = vim.v.foldstart ---@type number
  local fold_end = vim.v.foldend ---@type number

  local first = vim.api.nvim_buf_get_lines(0, fold_start - 1, fold_start, true)[1]
  local last = vim.api.nvim_buf_get_lines(0, fold_end - 1, fold_end, true)[1]

  local columns = vim.api.nvim_win_get_width(0)
  local line_count = fold_end - fold_start + 1

  -- 10 = format prefix width, 5 = sign/number column heuristic, 3 = separator
  local needed = #last + 10 + 5 + 3
  if #first + needed > columns then
    local overflow = math.abs(#first - columns)
    local remove = math.ceil(bit.rshift(overflow, 1) + needed + 5)
    local middle = bit.rshift(#first, 1)
    first = first:sub(1, middle - remove) .. " […] " .. first:sub(middle + remove)
  end

  return ("   %-6d%s"):format(line_count, table.concat({ first, last }, " … "))
end

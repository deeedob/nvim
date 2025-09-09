_G['RELOAD'] = function(modname)
    if vim then
        if vim.is_thread() then
            package.loaded[modname] = nil
        elseif vim.v.vim_did_enter == 1 then
            package.loaded[modname] = nil
            if vim.loader and vim.loader.enabled then
                vim.loader.reset(modname)
            end
        end
    else
        package.loaded[modname] = nil
    end
    return require(modname)
end

_G['P'] = function(...)
    local args = { ... }
    local inspected_args = vim.tbl_map(vim.inspect, args)
    print(table.unpack(inspected_args))
    return ...
end

_G['PRINT'] = _G['P']

_G['PASTE'] = function(data)
    if not vim then
        error(debug.traceback 'This platform is unsupported')
    end

    local tmp = data
    if not vim.isarray(tmp) then
        if type(tmp) == type '' then
            tmp = vim.split(tmp, '\n')
        else
            tmp = vim.split(vim.inspect(tmp), '\n')
        end
    else
        tmp = vim.deepcopy(tmp)
    end
    vim.paste(
        vim.tbl_map(function(v)
            return type(v) == type '' and v or vim.inspect(v)
        end, tmp),
        -1
    )
end

_G['PERF'] = function(msg, ...)
    local args = { ... }
    assert(type(args[1]) == 'function', debug.traceback 'The first argument must be a function')
    assert(not msg or type(msg) == 'string', debug.traceback 'msg must be a string')
    msg = msg or 'Func reference elpse time:'
    local func = args[1]
    table.remove(args, 1)
    -- local start = os.time()
    local start = os.clock()
    local data = func(unpack(args))
    print(msg, ('%.2f s'):format(os.clock() - start))
    -- print(msg, ('%.2f s'):format(os.difftime(os.time(), start)))
    return data
end


_G["NeatFoldText"] = function()
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

      local remove = math.ceil(bit.rshift(overflow, 1) + needed_width + 5)
      local middle = bit.rshift(first_line_len, 1)

      lines[1] = first_line:sub(1, middle - remove) .. ' […] ' .. first_line:sub(middle + remove)
    end
  end

  return ('   %-6d%s'):format(end_ - start + 1, table.concat(lines, ' … '))
end

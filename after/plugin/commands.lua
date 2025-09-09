local function stop_server(server, force)
  vim.iter(vim.lsp.get_clients { name = server }):each(function(client)
    client:stop(force)
  end)
  return true
end

--- Return a cmd separated by spaces
---@param cmdline string
---@return string[]
local function get_cmd(cmdline)
  return vim
    .iter(vim.split(cmdline, "%s+", { trimempty = true }))
    :map(vim.trim)
    :totable()
end

local function get_available_flags(cmd, options)
  return vim
    .iter(options)
    :filter(function(opt)
      return not vim.tbl_contains(cmd, opt)
    end)
    :totable()
end

local function filter(word, candidates)
  if word == "" then
    return candidates
  end

  -- split "foo.bar.baz" -> { "foo", "bar", "baz" }
  local components = vim.split(word, "%.", { plain = true, trimempty = true })
  local pattern = table.concat(components, ".*")

  return vim.tbl_filter(function(candidate)
    return candidate:lower():match(pattern) ~= nil
  end, candidates) or {}
end

--- completion function (replacement for utils.general_completion)
local function general_completion(arglead, cmdline, _, options, smart)
  local dashes
  if arglead:sub(1, 2) == "--" then
    dashes = "--"
  elseif arglead:sub(1, 1) == "-" then
    dashes = "-"
  end

  if smart ~= false then
    options = get_available_flags(get_cmd(cmdline), options --[[@as string[] ]])
  end

  local results = filter((arglead:gsub("%-", "")):lower(), options)
  return vim
    .iter(results)
    :map(function(arg)
      if dashes and arg:sub(1, #dashes) ~= dashes then
        return dashes .. arg
      end
      return arg
    end)
    :totable()
end

local completions = {}

completions.lsp_configs = function(arglead, cmdline, cursorpos)
  local configs = vim.api.nvim_get_runtime_file("after/lsp/*.lua", true)
  local confignames = vim
    .iter(configs)
    :map(function(path)
      local fname = vim.fs.basename(path) -- e.g. "pyright.lua"
      return fname:gsub("%.lua$", "") -- strip ".lua"
    end)
    :filter(function(configname)
      local config = vim.lsp.config[configname]
      return config and vim.list_contains(config.filetypes, vim.bo.filetype)
    end)
    :totable()
  return general_completion(arglead, cmdline, cursorpos, confignames)
end

completions.lsp_clients = function(arglead, cmdline, cursorpos)
  local servers = vim
    .iter(vim.lsp.get_clients())
    :map(function(client)
      return client.name
    end)
    :totable()
  return general_completion(arglead, cmdline, cursorpos, servers)
end

-- User commands
vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd.checkhealth "vim.lsp"
end, {
  nargs = 0,
  desc = "Open LSP info",
})

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.edit(vim.lsp.get_log_path())
end, {
  nargs = 0,
  desc = "Open LSP log",
})

vim.api.nvim_create_user_command("LspStart", function(opts)
  local name = opts.args
  local config = vim.lsp.config[name]
  vim.defer_fn(function()
    config.name = config.name or name
    vim.lsp.start(config, { bufnr = 0 })
  end, 1000)
end, {
  bang = true,
  nargs = 1,
  complete = completions.lsp_configs,
  desc = "Start an lsp server in the current buffer",
})

vim.api.nvim_create_user_command("LspStop", function(opts)
  local server = opts.args
  if stop_server(server, opts.bang) then
    vim.notify(
      string.format("%s stopped", server),
      vim.log.levels.INFO,
      { title = "LspStop" }
    )
  end
end, {
  bang = true,
  nargs = 1,
  complete = completions.lsp_clients,
  desc = "Stop an active lsp server",
})

vim.api.nvim_create_user_command("LspRestart", function(opts)
  local server = opts.args
  vim.notify(
    string.format("Restartting %s", server),
    vim.log.levels.INFO,
    { title = "LspRestart" }
  )
  if stop_server(server) then
    vim.lsp.enable(server, true)
  end
end, {
  bang = true,
  nargs = 1,
  complete = completions.lsp_clients,
  desc = "Restart an active lsp server",
})

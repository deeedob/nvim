-- LSP management commands that require plugins to already be loaded.
-- Placed in after/plugin/ so they are sourced after all plugins are set up.

local function stop_server(name, force)
  vim.iter(vim.lsp.get_clients({ name = name })):each(function(client)
    client:stop(force)
  end)
  return true
end

local function restart_server(name, force)
  local function start_fresh()
    local cfg = vim.deepcopy(vim.lsp.config[name] or {})
    cfg.name = cfg.name or name
    vim.lsp.start(cfg, { bufnr = 0 })
  end

  local clients = vim.lsp.get_clients({ name = name })
  if #clients == 0 then
    start_fresh()
    return true
  end

  local force_ms = force and 1000 or nil
  for _, client in ipairs(clients) do
    client:stop(force_ms)
  end

  -- Poll until all clients have stopped, then start fresh.
  -- Uses vim.uv (Neovim 0.10+) — not the deprecated vim.loop alias.
  local timer = vim.uv.new_timer()
  timer:start(50, 50, function()
    if #vim.lsp.get_clients({ name = name }) == 0 then
      timer:stop()
      timer:close()
      vim.schedule(start_fresh)
    end
  end)

  return true
end

--- Split a command string into an argv-style table.
---@param cmdline string
---@return string[]
local function get_cmd(cmdline)
  return vim.iter(vim.split(cmdline, "%s+", { trimempty = true })):map(vim.trim):totable()
end

--- Return only those options that are not already present in cmd.
local function get_available_flags(cmd, options)
  return vim
    .iter(options)
    :filter(function(opt)
      return not vim.tbl_contains(cmd, opt)
    end)
    :totable()
end

--- Fuzzy-filter candidates by a dotted-component pattern.
local function filter(word, candidates)
  if word == "" then
    return candidates
  end
  local pattern = table.concat(vim.split(word, "%.", { plain = true, trimempty = true }), ".*")
  return vim.tbl_filter(function(c)
    return c:lower():match(pattern) ~= nil
  end, candidates)
end

--- Generic tab-completion function for user commands.
local function general_completion(arglead, cmdline, _, options, smart)
  local dashes
  if arglead:sub(1, 2) == "--" then
    dashes = "--"
  elseif arglead:sub(1, 1) == "-" then
    dashes = "-"
  end

  if smart ~= false then
    options = get_available_flags(get_cmd(cmdline), options)
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
  -- Configs live in lsp/*.lua (native 0.11 location)
  local paths = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
  local names = vim
    .iter(paths)
    :map(function(path)
      return vim.fs.basename(path):gsub("%.lua$", "")
    end)
    :filter(function(name)
      local cfg = vim.lsp.config[name]
      return cfg and vim.list_contains(cfg.filetypes or {}, vim.bo.filetype)
    end)
    :totable()
  return general_completion(arglead, cmdline, cursorpos, names)
end

completions.lsp_clients = function(arglead, cmdline, cursorpos)
  local names = vim
    .iter(vim.lsp.get_clients())
    :map(function(c)
      return c.name
    end)
    :totable()
  return general_completion(arglead, cmdline, cursorpos, names)
end

-- ── User commands ─────────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd.checkhealth("vim.lsp")
end, { nargs = 0, desc = "Show LSP info" })

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.edit(vim.lsp.get_log_path())
end, { nargs = 0, desc = "Open LSP log" })

vim.api.nvim_create_user_command("LspStart", function(opts)
  local name = opts.args
  local config = vim.lsp.config[name]
  if not config then
    vim.notify(("No LSP config found for '%s'"):format(name), vim.log.levels.WARN)
    return
  end
  vim.defer_fn(function()
    config.name = config.name or name
    vim.lsp.start(config, { bufnr = 0 })
  end, 1000)
end, {
  bang = true,
  nargs = 1,
  complete = completions.lsp_configs,
  desc = "Start an LSP server in the current buffer",
})

vim.api.nvim_create_user_command("LspStop", function(opts)
  local name = opts.args
  if stop_server(name, opts.bang) then
    vim.notify(("%s stopped"):format(name), vim.log.levels.INFO, { title = "LspStop" })
  end
end, {
  bang = true,
  nargs = 1,
  complete = completions.lsp_clients,
  desc = "Stop an active LSP server",
})

vim.api.nvim_create_user_command("LspRestart", function(opts)
  local name = opts.args
  vim.notify(("Restarting %s"):format(name), vim.log.levels.INFO, { title = "LspRestart" })
  if not restart_server(name, opts.bang) then
    vim.notify(("%s is not running"):format(name), vim.log.levels.WARN, { title = "LspRestart" })
  end
end, {
  bang = true,
  nargs = 1,
  complete = completions.lsp_clients,
  desc = "Restart an active LSP server",
})

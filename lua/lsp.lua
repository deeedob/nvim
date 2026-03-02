local M = {}

local function make_capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  caps.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return caps
end

local function enable_servers()
  local servers = {}
  for _, f in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    servers[#servers + 1] = vim.fn.fnamemodify(f, ":t:r")
  end
  vim.lsp.enable(servers)
end

local function set_diagnostic_hl()
  for severity, hl_name in pairs({
    Error = "DiagnosticError",
    Warn = "DiagnosticWarn",
    Info = "DiagnosticInfo",
    Hint = "DiagnosticHint",
  }) do
    local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
    if hl and hl.fg then
      vim.api.nvim_set_hl(0, "ColumnDiagnostic" .. severity, { fg = hl.fg })
    end
  end
  vim.api.nvim_set_hl(0, "SyntasticErrorLine", { link = "SignColumn" })
end

local function map(mode, lhs, rhs, desc, bufnr)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    silent = true,
    noremap = true,
    desc = desc,
  })
end

local function notify_unsupported(desc, client)
  vim.notify(
    string.format("[LSP] %s (not supported by %s)", desc, client and client.name or "client"),
    vim.log.levels.INFO
  )
end

local function cap_map(client, bufnr, method, mode, lhs, rhs, desc)
  if client and client:supports_method(method) then
    map(mode, lhs, rhs, desc, bufnr)
  else
    map(mode, lhs, function()
      notify_unsupported(desc, client)
    end, desc .. " (unsupported)", bufnr)
  end
end

local function trouble()
  return require("trouble")
end

local providers = {
  definitions = function()
    trouble().open({ mode = "lsp_definitions", focus = true })
  end,
  declarations = function()
    trouble().open({ mode = "lsp_declarations", focus = true })
  end,
  type_definitions = function()
    trouble().open({ mode = "lsp_type_definitions", focus = true })
  end,
  references = function()
    trouble().open({ mode = "lsp_references", focus = true })
  end,

  incoming_calls = function()
    trouble().open("lsp_incoming_calls")
  end,
  outgoing_calls = function()
    trouble().open("lsp_outgoing_calls")
  end,
  document_symbols = function()
    trouble().toggle({ mode = "lsp_document_symbols", win = { position = "right" } })
  end,
}

local function stop_clients_with_no_buffers()
  for _, client in ipairs(vim.lsp.get_clients()) do
    local has_loaded = false
    for bufnr, attached in pairs(client.attached_buffers or {}) do
      if attached and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
        has_loaded = true
        break
      end
    end
    if not has_loaded then
      vim.lsp.stop_client(client.id)
    end
  end
end

local augroup = vim.api.nvim_create_augroup("ddob/lsp-attach", { clear = true })
local function attach_keymaps(client, bufnr)
  -- Hover/signature (buffer-local)
  cap_map(client, bufnr, "textDocument/hover", "n", "K", vim.lsp.buf.hover, "Hover docs")
  cap_map(
    client,
    bufnr,
    "textDocument/signatureHelp",
    { "n", "i" },
    "<C-s>",
    vim.lsp.buf.signature_help,
    "Signature help"
  )

  -- Navigation (Trouble provider)
  map("n", "gd", providers.definitions, "Goto definition", bufnr)
  map("n", "gD", providers.declarations, "Goto declaration", bufnr)
  map("n", "gT", providers.type_definitions, "Goto type definition", bufnr)
  map("n", "gr", providers.references, "Goto references", bufnr)

  -- LSP actions (capability guarded + notify stubs)
  cap_map(
    client,
    bufnr,
    "textDocument/codeAction",
    "n",
    "<leader>la",
    vim.lsp.buf.code_action,
    "Code actions"
  )
  cap_map(
    client,
    bufnr,
    "textDocument/rename",
    "n",
    "<leader>lr",
    vim.lsp.buf.rename,
    "Rename symbol"
  )

  -- Trouble-only extras (still lazy require)
  map("n", "<leader>li", providers.incoming_calls, "Incoming calls", bufnr)
  map("n", "<leader>lo", providers.outgoing_calls, "Outgoing calls", bufnr)
  map("n", "<leader>ls", providers.document_symbols, "Document symbols", bufnr)
end

local function setup_attach()
  set_diagnostic_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = set_diagnostic_hl,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(event)
      if vim.g.vscode then
        return
      end

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if not client then
        return
      end

      local bufnr = event.buf
      attach_keymaps(client, bufnr)

      if client:supports_method("textDocument/foldingRange") then
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
    group = vim.api.nvim_create_augroup("ddob/lsp-autostop", { clear = true }),
    callback = function()
      vim.schedule(stop_clients_with_no_buffers)
    end,
  })
end

function M.setup()
  if vim.env.NVIM_LSP_DEBUG then
    vim.lsp.set_log_level(vim.log.levels.DEBUG)
    vim.notify("LSP logging: DEBUG\n" .. vim.lsp.get_log_path())
  end

  local caps = make_capabilities()
  vim.lsp.config("*", { capabilities = caps })

  enable_servers()
  setup_attach()
end

return M

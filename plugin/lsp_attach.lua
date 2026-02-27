local augroup = vim.api.nvim_create_augroup("ddob/lsp-attach", { clear = true })

-- ── Trouble navigation helpers ────────────────────────────────────────────────
-- Defined once here; referenced by name below to avoid repeating the table
-- construction on every attach.
local trouble = {
  definitions = function()
    require("trouble").open({ mode = "lsp_definitions", focus = true })
  end,
  declarations = function()
    require("trouble").open({ mode = "lsp_declarations", focus = true })
  end,
  type_definitions = function()
    require("trouble").open({ mode = "lsp_type_definitions", focus = true })
  end,
  references = function()
    require("trouble").open({ mode = "lsp_references", focus = true })
  end,
  implementations = function()
    require("trouble").open("lsp_implementations")
  end,
  incoming_calls = function()
    require("trouble").open("lsp_incoming_calls")
  end,
  outgoing_calls = function()
    require("trouble").open("lsp_outgoing_calls")
  end,
  document_symbols = function()
    require("trouble").toggle({ mode = "lsp_document_symbols", win = { position = "right" } })
  end,
}

-- ── Buffer-local keymap helper ────────────────────────────────────────────────
local function map(mode, lhs, rhs, desc, bufnr)
  vim.keymap.set(mode, lhs, rhs, {
    silent = true,
    noremap = true,
    buffer = bufnr, -- always buffer-local; bufnr = 0 means current buffer
    desc = desc,
  })
end

-- ── Diagnostic column highlights ─────────────────────────────────────────────
-- Link the NumHL group to the corresponding diagnostic colour so line numbers
-- are coloured when a diagnostic is present on that line.
local function set_diagnostic_hl()
  for severity, hl_name in pairs({
    Error = "DiagnosticError",
    Warn = "DiagnosticWarn",
    Info = "DiagnosticInfo",
    Hint = "DiagnosticHint",
  }) do
    local fg = vim.api.nvim_get_hl(0, { name = hl_name, link = false }).fg
    if fg then
      vim.api.nvim_set_hl(0, "ColumnDiagnostic" .. severity, { fg = fg })
    end
  end
  vim.api.nvim_set_hl(0, "SyntasticErrorLine", { link = "SignColumn" })
end

-- ── Per-buffer keymaps ────────────────────────────────────────────────────────
local function attach_keymaps(bufnr)
  -- Hover and signature (both buffer-local — hover must NOT be global)
  map("n", "K", vim.lsp.buf.hover, "Hover docs", bufnr)
  map({ "n", "i" }, "<C-s>", vim.lsp.buf.signature_help, "Signature help", bufnr)

  -- Navigation (via Trouble)
  map("n", "gd", trouble.definitions, "Goto definition", bufnr)
  map("n", "gD", trouble.declarations, "Goto declaration", bufnr)
  map("n", "gT", trouble.type_definitions, "Goto type definition", bufnr)
  map("n", "gr", trouble.references, "Goto references", bufnr)

  -- LSP actions
  map("n", "<leader>la", vim.lsp.buf.code_action, "Code actions", bufnr)
  map("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol", bufnr)
  map("n", "<leader>li", trouble.incoming_calls, "Incoming calls", bufnr)
  map("n", "<leader>lo", trouble.outgoing_calls, "Outgoing calls", bufnr)
  map("n", "<leader>ls", trouble.document_symbols, "Document symbols", bufnr)
end

-- ── LspAttach handler ─────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  pattern = "*",
  callback = function(event)
    -- Skip in VSCode — it has its own LSP UI
    if vim.g.vscode then
      return
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    set_diagnostic_hl()
    attach_keymaps(event.buf)
  end,
})

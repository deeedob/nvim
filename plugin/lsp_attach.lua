local augroup = vim.api.nvim_create_augroup("ddob/lsp-attach", { clear = true })

local trouble = {
  references = function()
    require("trouble").open {
      mode = "lsp_references",
      focus = true,
    }
  end,
  definitions = function()
    require("trouble").open {
      mode = "lsp_definitions",
      focus = true,
    }
  end,
  declarations = function()
    require("trouble").open {
      mode = "lsp_declarations",
      focus = true,
    }
  end,
  type_definitions = function()
    require("trouble").open {
      mode = "lsp_type_definitions",
      focus = true,
    }
  end,
  implementations = function()
    require("trouble").open "lsp_implementations"
  end,
  incoming_calls = function()
    require("trouble").open "lsp_incoming_calls"
  end,
  outgoing_calls = function()
    require("trouble").open "lsp_outgoing_calls"
  end,
  document_symbol = function()
    require("trouble").toggle {
      mode = "lsp_document_symbols",
      win = {
        position = "right",
      },
    }
  end
}

local function diagnostics()
  vim.diagnostic.config {
    underline = true,
    virtual_text = false,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "ColumnDiagnosticError",
        [vim.diagnostic.severity.WARN] = "ColumnDiagnosticWarn",
        [vim.diagnostic.severity.INFO] = "ColumnDiagnosticInfo",
        [vim.diagnostic.severity.HINT] = "ColumnDiagnosticHint",
      },
    },
    update_in_insert = true,
    severity_sort = true,
    float = {
      scope = "line",
      border = "rounded",
      header = "",
      prefix = " ",
      focusable = false,
      source = true,
    },
  }

  -- Highlight the NumColumn with diagnostic output
  vim.cmd [[
    exec 'hi ColumnDiagnosticHint guifg=' . synIDattr(hlID('DiagnosticHint'), 'fg')
    exec 'hi ColumnDiagnosticInfo guifg=' . synIDattr(hlID('DiagnosticInfo'), 'fg')
    exec 'hi ColumnDiagnosticWarn guifg=' . synIDattr(hlID('DiagnosticWarn'), 'fg')
    exec 'hi ColumnDiagnosticError guifg=' . synIDattr(hlID('DiagnosticError'), 'fg')
    hi link SyntasticErrorLine SignColumn
  ]]
end

local function keymaps(bufnr, client)

  vim.keymap.set(
    "n",
    "K",
    vim.lsp.buf.hover,
    { desc = "Hover lsp docs", buffer = bufnr }
  )
  vim.keymap.set(
    { "n", "i" },
    "<C-s>",
    vim.lsp.buf.signature_help,
    { desc = "Signature Help", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "gd",
    trouble.definitions,
    { desc = "Goto [d]efinition", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "gD",
    trouble.declarations,
    { desc = "Goto [D]eclaration", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "gT",
    trouble.type_definitions,
    { desc = "Goto [T]ype", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "gr",
    trouble.references,
    { desc = "Goto [R]eferences", buffer = bufnr }
  )

  vim.keymap.set(
    "n",
    "<leader>la",
    vim.lsp.buf.code_action,
    { desc = "Code [A]ctions", buffer = 0 }
  )
  vim.keymap.set(
    "n",
    "<leader>lr",
    vim.lsp.buf.rename,
    { desc = "[R]ename", buffer = 0 }
  )
  vim.keymap.set(
    "n",
    "<leader>li",
    trouble.incoming_calls,
    { desc = "[I]ncoming Calls", buffer = 0 }
  )
  vim.keymap.set(
    "n",
    "<leader>lo",
    trouble.outgoing_calls,
    { desc = "[O]outgoing Calls", buffer = 0 }
  )
  vim.keymap.set(
    "n",
    "<leader>ld",
    vim.diagnostic.open_float,
    { desc = "[D]iagnostic Line", buffer = 0 }
  )
  vim.keymap.set(
    "n",
    "<leader>ls",
    vim.lsp.buf.document_symbol,
    { desc = "[S]ymbols", buffer = 0 }
  )
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	pattern = "*",
	callback = function(event)
		if vim.g.vscode then
			return
		end

		local bufnr = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		diagnostics()
		keymaps(bufnr, client)
	end,
})

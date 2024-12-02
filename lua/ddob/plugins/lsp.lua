return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/neodev.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Schema information
      "b0o/SchemaStore.nvim",

      -- Autoformatting
      "stevearc/conform.nvim",

      -- handler for definitions, references, outline ...
      "folke/trouble.nvim",
    },
    config = function()
      require("neodev").setup {
        -- library = {
        --   plugins = { "nvim-dap-ui" },
        --   types = true,
        -- },
      }

      local capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      local lspconfig = require "lspconfig"

      local servers = {
        clangd = {
          init_options = {
            -- clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          on_new_config = function(new_config, new_cwd)
            local status, cmake = pcall(require, "cmake-tools")
            if status then
              cmake.clangd_on_new_config(new_config)
            end
          end,
          cmd = {
            "clangd",
            "--all-scopes-completion",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed", -- or bundled
            "--header-insertion=iwyu",
            "--function-arg-placeholders",
            "--enable-config", -- uses ~/.local/clangd/config.yaml
            -- "--query-driver=/usr/bin/clang++,/usr/bin/g++",
            -- clangd performance
            "-j=16",
            "--malloc-trim",
            "--background-index",
            "--pch-storage=memory", -- increases memory usage but improves performance, memory, disk
            -- stash
            -- "--cross-file-rename", got removed? without explanation?!
            -- "--rename-file-limit=400",
          },
        },
        qmlls = {
          manual_install = true,
          cmd = {
            "qmlls",
          },
          filetypes = { "qml" },
          single_file_support = true,
        },
        neocmake = true,
        bashls = true,
        lua_ls = {
          server_capabilities = {
            semanticTokensProvider = vim.NIL,
          },
        },
        rust_analyzer = true,
        marksman = true,
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        },
        pyright = {},
        typst_lsp = {},
        bufls = {},
      }

      local servers_to_install = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == "table" then
          return not t.manual_install
        else
          return t
        end
      end, vim.tbl_keys(servers))

      require("mason").setup()
      local ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "prettier",
        "buf",
        "markdownlint",
        "cmakelint",
        "cmakelang",
        "clang-format",
      }

      vim.list_extend(ensure_installed, servers_to_install)
      require("mason-tool-installer").setup {
        ensure_installed = ensure_installed,
      }

      for name, config in pairs(servers) do
        if config == true then
          config = {}
        end
        config = vim.tbl_deep_extend("force", {}, {
          capabilities = capabilities,
        }, config)

        lspconfig[name].setup(config)
      end

      local disable_semantic_tokens = {
        lua = true,
        typst = true,
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = assert(
            vim.lsp.get_client_by_id(args.data.client_id),
            "must have valid client"
          )
          local settings = servers[client.name]
          if type(settings) ~= "table" then
            settings = {}
          end

          vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
          vim.keymap.set(
            "n",
            "K",
            vim.lsp.buf.hover,
            { desc = "Hover lsp docs", buffer = 0 }
          )
          vim.keymap.set(
            { "n", "i" },
            "<C-s>",
            vim.lsp.buf.signature_help,
            { desc = "Signature Help", buffer = 0 }
          )
          vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            { desc = "Goto [d]efinition", buffer = 0 }
          )
          vim.keymap.set(
            "n",
            "gD",
            vim.lsp.buf.declaration,
            { desc = "Goto [D]eclaration", buffer = 0 }
          )
          vim.keymap.set(
            "n",
            "gT",
            vim.lsp.buf.type_definition,
            { desc = "Goto [T]ype", buffer = 0 }
          )
          vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            { desc = "Goto [R]eferences", buffer = 0 }
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
            vim.lsp.buf.incoming_calls,
            { desc = "[I]ncoming Calls", buffer = 0 }
          )
          vim.keymap.set(
            "n",
            "<leader>lo",
            vim.lsp.buf.outgoing_calls,
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

          local filetype = vim.bo[bufnr].filetype
          if disable_semantic_tokens[filetype] then
            client.server_capabilities.semanticTokensProvider = nil
          end

          if settings.server_capabilities then
            for k, v in pairs(settings.server_capabilities) do
              if v == vim.NIL then
                ---@diagnostic disable-next-line: cast-local-type
                v = nil
              end
              client.server_capabilities[k] = v
            end
          end
        end,
      })

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
      vim.cmd [[
        " Highlight the NumColumn with diagnostic output
        exec 'hi ColumnDiagnosticHint guifg=' . synIDattr(hlID('DiagnosticHint'), 'fg')
        exec 'hi ColumnDiagnosticInfo guifg=' . synIDattr(hlID('DiagnosticInfo'), 'fg')
        exec 'hi ColumnDiagnosticWarn guifg=' . synIDattr(hlID('DiagnosticWarn'), 'fg')
        exec 'hi ColumnDiagnosticError guifg=' . synIDattr(hlID('DiagnosticError'), 'fg')
        hi link SyntasticErrorLine SignColumn
      ]]

      local default_clang = "file"
      local has_local_clang = vim.fn.filereadable ".clang-format" == 1
      if not has_local_clang then
        default_clang = "file:"
          .. os.getenv "HOME"
          .. "/.config/clangd/.clang-format"
      end
      require("conform").setup {
        format = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
        },
        formatters = {
          clang_format = {
            args = {
              "--assume-filename",
              "$FILENAME",
              "--style",
              default_clang,
            },
          },
        },
        formatters_by_ft = {
          lua = { "stylua" },
          cpp = { "clang_format" },
          cmake = { "cmake_format" },
          sh = { "shfmt" },

          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
        },
      }

      vim.keymap.set({ "n", "v" }, "<leader>lf", function()
        require("conform").format {
          async = true,
          lsp_fallback = false,
        }
      end, { desc = "[f]ormat buffer" })

      vim.keymap.set({ "n", "v" }, "<leader>lg", function()
        local ignore_filetypes = { "lua" }
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
          vim.notify(
            "range formatting for "
              .. vim.bo.filetype
              .. " not working properly."
          )
          return
        end

        local hunks = require("gitsigns").get_hunks()
        if hunks == nil or next(hunks) == nil then
          vim.notify("no git hunks to format", "info", { title = "formating" })
          return
        end

        local format = require("conform").format
        local function format_range()
          if next(hunks) == nil then
            vim.notify(
              "done formatting git hunks",
              "info",
              { title = "formatting" }
            )
            return
          end
          local hunk = nil
          while next(hunks) ~= nil and (hunk == nil or hunk.type == "delete") do
            hunk = table.remove(hunks)
          end

          if hunk ~= nil and hunk.type ~= "delete" then
            local start = hunk.added.start
            local last = start + hunk.added.count
            -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
            local last_hunk_line =
              vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
            local range = {
              start = { start, 0 },
              ["end"] = { last - 1, last_hunk_line:len() },
            }
            format(
              { range = range, async = true, lsp_fallback = true },
              function()
                vim.defer_fn(function()
                  format_range()
                end, 1)
              end
            )
          end
        end

        format_range()
      end, { desc = "Format [g]it hunks" })

      require("trouble").setup {}
      local trouble = {}

      trouble.references = function(_)
        require("trouble").open {
          mode = "lsp_references",
          focus = true,
        }
      end
      trouble.definitions = function(_)
        require("trouble").open {
          mode = "lsp_definitions",
          focus = true,
        }
      end
      trouble.declarations = function(_)
        require("trouble").open {
          mode = "lsp_declarations",
          focus = true,
        }
      end
      trouble.type_definitions = function(_)
        require("trouble").open {
          mode = "lsp_type_definitions",
          focus = true,
        }
      end
      trouble.implementations = function(_)
        require("trouble").open "lsp_implementations"
      end
      trouble.incoming_calls = function(_)
        require("trouble").open "lsp_incoming_calls"
      end
      trouble.outgoing_calls = function(_)
        require("trouble").open "lsp_outgoing_calls"
      end
      trouble.document_symbol = function(_)
        require("trouble").toggle {
          mode = "lsp_document_symbols",
          win = {
            position = "right",
          },
        }
      end

      vim.lsp.handlers["textDocument/references"] =
        vim.lsp.with(trouble.references, {})

      vim.lsp.handlers["textDocument/definition"] =
        vim.lsp.with(trouble.definitions, {})

      vim.lsp.handlers["textDocument/declaration"] =
        vim.lsp.with(trouble.declarations, {})

      vim.lsp.handlers["textDocument/typeDefinition"] =
        vim.lsp.with(trouble.type_definitions, {})

      vim.lsp.handlers["textDocument/implementation"] =
        vim.lsp.with(trouble.implementations, {})

      vim.lsp.handlers["textDocument/documentSymbol"] =
        vim.lsp.with(trouble.document_symbol, {})

      vim.lsp.handlers["callHierarchy/incomingCalls"] =
        vim.lsp.with(trouble.incoming_calls, {})

      vim.lsp.handlers["callHierarchy/outgoingCalls"] =
        vim.lsp.with(trouble.outgoing_calls, {})

      vim.keymap.set("n", "<leader>lt", function()
        require("trouble").toggle()
      end, { desc = "Trouble [t]oggle" })

      vim.keymap.set("n", "<leader>lP", function()
        require("trouble").toggle {
          mode = "diagnostics",
        }
      end, { desc = "Diagnostic (Project)" })

      vim.keymap.set(
        "n",
        "<leader>lD",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        { desc = "Diagnostic (Buffer)" }
      )

      -- Automatically Open Trouble Quickfix
      vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        callback = function()
          vim.cmd [[Trouble qflist open]]
        end,
      })
    end,
  },
}

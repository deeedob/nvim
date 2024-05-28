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
      "DNLHC/glance.nvim",
      "hedyhli/outline.nvim",
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
          filetypes = { "c", "cpp", "objc", "objcpp" },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--header-insertion-decorators",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--cross-file-rename",
            "--enable-config",
            "--query-driver=/usr/bin/clang++",
            "-j=4",
          },
        },
        neocmake = true,
        bashls = true,
        lua_ls = true,
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
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          -- local bufnr = args.buf
          local client = assert(
            vim.lsp.get_client_by_id(args.data.client_id),
            "must have valid client"
          )
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

          -- vim.api.nvim_create_autocmd("CursorHold", {
          --   group = vim.api.nvim_create_augroup("ddob_diagnostic_hover", { clear = true }),
          --   buffer = 0,
          --   callback = function()
          --     local opts = {
          --       focusable = false,
          --       close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          --       border = "rounded",
          --       source = "always",
          --       prefix = " ",
          --       scope = "line",
          --     }
          --     vim.diagnostic.open_float(nil, opts)
          --   end,
          -- })

          local filetype = vim.bo[0].filetype
          if disable_semantic_tokens[filetype] then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })

      -- TODO: https://github.com/stevearc/conform.nvim/issues/92
      require("conform").setup {
        format = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
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

      vim.keymap.set("n", "<leader>lf", function()
        require("conform").format {
          async = true,
          lsp_fallback = false,
        }
      end, { desc = "Format buffer" })

      ---@diagnostic disable-next-line: missing-fields
      require("glance").setup {
        height = 13,
        detached = false,
        list = {
          position = "left",
          width = 0.33,
        },
        theme = {
          enable = true,
          mode = "auto",
        },
        hooks = {
          before_open = function(results, open, jump, method)
            if #results == 1 then
              jump(results[1])
            else
              open(results)
            end
          end,
        },
      }

      local glance = {}
      glance.references = function(opts)
        require("glance").open "references"
      end
      glance.definitions = function(opts)
        require("glance").open "definitions"
      end
      glance.implementations = function(opts)
        require("glance").open "implementations"
      end
      glance.type_definitions = function(opts)
        require("glance").open "type_definitions"
      end

      vim.lsp.handlers["textDocument/references"] =
        vim.lsp.with(glance.references, {})

      vim.lsp.handlers["textDocument/definition"] =
        vim.lsp.with(glance.definitions, {})

      vim.lsp.handlers["textDocument/typeDefinition"] =
        vim.lsp.with(glance.type_definitions, {})

      vim.lsp.handlers["textDocument/implementation"] =
        vim.lsp.with(glance.implementations, {})

      require("outline").setup()

      local outline = {}
      outline.documentSymbol = function (opts)
        vim.cmd("Outline")
      end

      vim.lsp.handlers["textDocument/documentSymbol"] =
        vim.lsp.with(outline.documentSymbol, {})

    end,
  },
}

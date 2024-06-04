return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function()
          require("clangd_extensions.inlay_hints").setup_autocmd()
          require("clangd_extensions.inlay_hints").set_inlay_hints()
        end,
      })
      return {
        inlay_hints = { inline = false },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
        },
      }
    end,
  },

  {
    "gauteh/vim-cppman",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    config = function()
      vim.keymap.set("n", "KK", function()
        local word = vim.fn.expand "<cword>"
        local escaped_word = vim.fn.fnameescape(word)
        vim.cmd("Cppman " .. escaped_word)
      end, { desc = "Open cppman" })
    end,
  },
}

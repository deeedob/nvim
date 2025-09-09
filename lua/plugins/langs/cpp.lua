return {
  {
    "Badhi/nvim-treesitter-cpp-tools",
    name = "nt-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    cmd = {
      "TSCppDefineClassFunc",
      "TSCppMakeConcreteClass",
      "TSCppRuleOf3",
      "TSCppRuleOf5",
    },
    config = function()
      local cpp_tools = vim.F.npcall(require, "nt-cpp-tools")
      if cpp_tools then
        cpp_tools.setup {
          preview = {
            quit = "<ESC>",
            accept = "i",
          },
          header_extension = "hpp",
          source_extension = "cpp",
        }
      end
    end,
  },

  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = {
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
    },
  },

  {
    "madskjeldgaard/cppman.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      local cppman = require "cppman"
      cppman.setup()
      vim.keymap.set("n", "<leader>cDc", function()
        cppman.input()
      end, { desc = "open cpp search" })
      vim.keymap.set(
        "n",
        "<leader>cDp",
        "<cmd>lua require('cppman').open_cppman_for(vim.fn.expand('<cword>'))<cr>",
        { desc = "Open cppman for word under cursor" }
      )
    end,
  },
}

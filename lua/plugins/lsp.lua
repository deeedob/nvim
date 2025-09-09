return {

  {
    "b0o/SchemaStore.nvim",
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "folke/trouble.nvim",
    opts = {},
    event = "VeryLazy",
  },

  {
    "HiPhish/jinja.vim",
    lazy = false,
  },
}

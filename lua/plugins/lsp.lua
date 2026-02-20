return {

  {
    "b0o/SchemaStore.nvim",
  },

  {
    "folke/lazydev.nvim",
    -- ft = "lua",
    lazy = false,
    opts = {
      -- lua_root = false,
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

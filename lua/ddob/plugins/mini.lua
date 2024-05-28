return {
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup()
      require("mini.surround").setup()
      require("mini.pairs").setup {
        mappings = {
          ["`"] = {
            action = "closeopen",
            pair = "``",
            neigh_pattern = "[^\\`].",
            register = { cr = false },
          },
        },
      }
      -- require("mini.bracketed").setup()
    end,
  },
}

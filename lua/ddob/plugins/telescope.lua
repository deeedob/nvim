return {
  {
    "nvim-telescope/telescope.nvim",
    -- git_bcommit_range missing
    -- https://github.com/nvim-telescope/telescope.nvim/issues/3080
    -- branch = "0.1.x",
    branch = "master",
    cmd = "Telescope",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
      "nvim-telescope/telescope-smart-history.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-frecency.nvim"
    },
    config = function()
      require "ddob.telescope"
    end
  },
}

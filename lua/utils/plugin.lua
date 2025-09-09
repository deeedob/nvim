local M = {}

M.setup = function(plugin_dir)
  vim.validate({ name = { plugin_dir, "string" } })
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  if not vim.uv.fs_stat(lazypath) then
    local out =
      vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to clone lazy.nvim:\n"
                  .. "  " .. out .. "\n"
                  .. "Press any key to exit...", vim.log.levels.ERROR)
      vim.fn.getchar()
      os.exit(1)
    end
  end

  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup({ import = plugin_dir }, {
    defaults = {
        lazy = false,
    },
    local_spec = false, -- disable .lazy.lua
    rocks = {
      enabled = false,
    },
    install = {
      colorscheme = {},
    },
    change_detection = {
      enabled = false,
      notify = false,
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "rplugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
end

M.exists = function (name)
  vim.validate({ name = { name, "string" } })
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    return false
  end
  local plugin = lazy.plugins()[name]
  return plugin
end

M.loaded = function (name)
  local p = M.is_present(name)
  return p and p._.loaded or false
end

return M

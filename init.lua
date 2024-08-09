vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.termguicolors = true
vim.o.guicursor = "n-v-c-sm:block-Cursor,"
  .. "i-ci-ve:ver30-blinkwait200-blinkon800,"
  .. "r-cr-o:hor20"
-- .. "a:Cursor"

vim.api.nvim_command "colorscheme ddob-kanagawa"

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ import = "ddob/plugins" }, {
  change_detection = {
    notify = false,
  },
})

require("ddob.utils").resetTerminalBg()

vim.cmd([[
    if has('nvim')
        let $GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
    endif
]])

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/clangd.lua

local base_cmd = {
  "clangd",
  "--all-scopes-completion",
  "--clang-tidy",
  "--header-insertion=never",
  "--function-arg-placeholders=1",
  "--background-index",
  "--pch-storage=memory",
  "--enable-config",
}

local root_markers = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  ".git",
}

return {
  cmd = function(dispatchers, config)
    local cmd = vim.deepcopy(base_cmd)

    if vim.lsp.log.get_level() <= vim.log.levels.DEBUG then
      table.insert(cmd, "--log=verbose")
    elseif vim.lsp.log.get_level() < vim.log.levels.ERROR then
      table.insert(cmd, "--log=info")
    end

    local cmake = require "cmake-tools"
    if cmake.is_cmake_project() then
      local build_dir = cmake.get_build_directory()
      if build_dir and build_dir.filename then
        local dir = vim.fn.fnamemodify(build_dir.filename, ":p")
        table.insert(cmd, "--compile-commands-dir=" .. dir)
      end
    end

    local sysname = vim.uv.os_uname().sysname:lower()
    if sysname == "linux" then
      table.insert(cmd, "--malloc-trim")
    end

    return vim.lsp.rpc.start(cmd, dispatchers, config)
  end,

  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = root_markers,

  init_options = {
    fallbackFlags = {
      "-Wall",
      "-Wextra",
      "-Wshadow",
      "-Wnon-virtual-dtor",
      "-Wold-style-cast",
      "-Wcast-align",
      "-Wunused",
      "-Woverloaded-virtual",
      "-Wpedantic",
      "-Wno-missing-prototypes",
      "-Wconversion",
      "-Wsign-conversion",
      "-Wnull-dereference",
      "-Wdouble-promotion",
      "-Wformat=2",
    },
  },

  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },

  on_attach = function(client, bufnr)
    vim.keymap.set(
      "n",
      "<leader>ll",
      "<cmd>ClangdSwitchSourceHeader<cr>",
      { desc = "Switch Source/Header (C/C++)", buffer = bufnr }
    )
    vim.keymap.set(
      "n",
      "<leader>lA",
      "<cmd>ClangdAST<cr>",
      { desc = "AST toggle (C/C++)", buffer = bufnr }
    )
    vim.keymap.set(
      "n",
      "<leader>ui",
      "<cmd>ClangdToggleInlayHints<cr>",
      { desc = "LSP Toggle Inlay Hints (C/C++)", buffer = bufnr }
    )
  end,
}

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
  "--query-driver=/usr/bin/g++",
}

local root_markers = {
  ".git",
  ".clang-format",
  ".clang-tidy",
  ".clangd",
}

return {
  cmd = function(dispatchers, config)
    local cmd = vim.deepcopy(base_cmd)

    local loglevel = vim.lsp.log.get_level()
    if loglevel <= vim.log.levels.DEBUG then
      table.insert(cmd, "--log=verbose")
    elseif loglevel < vim.log.levels.ERROR then
      table.insert(cmd, "--log=info")
    else
      table.insert(cmd, "--log=erro")
    end

    local cmake = require("cmake-tools")
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
  reuse_client = function(client, config)
    return true
  end,
  root_markers = root_markers,

  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },

  capabilities = {
    textDocument = {
      semanticHighlightingCapabilities = {
        semanticHighlighting = true,
      },
      completion = {
        editsNearCursor = true,
      },
    },
    -- offsetEncoding = { "utf-8", "utf-16" }, deprecated. Use positionEncodings
  },

  on_attach = function(client, bufnr)
    vim.keymap.set("n", "<leader>ll", "<cmd>ClangdSwitchSourceHeader<cr>", {
      desc = "Switch source/header (C/C++)",
      buffer = bufnr,
      silent = true,
    })
    vim.keymap.set("n", "<leader>lA", "<cmd>ClangdAST<cr>", {
      desc = "AST toggle (C/C++)",
      buffer = bufnr,
      silent = true,
    })
    vim.keymap.set("n", "<leader>ui", "<cmd>ClangdToggleInlayHints<cr>", {
      desc = "Toggle inlay hints (C/C++)",
      buffer = bufnr,
      silent = true,
    })
  end,
}

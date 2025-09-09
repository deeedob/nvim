-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/clangd.lua
local compile_db = "compile_commands.json"

local root_markers = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  compile_db,
  "compile_flags.txt",
  "configure.ac", -- AutoTools
  -- 'Makefile',
  "CMakeLists.txt",
  ".git",
}

local default_cmd = {
  "clangd",
  "--all-scopes-completion",
  "--clang-tidy",
  "--header-insertion=never",
  "--function-arg-placeholders",
  "--background-index",
  "--pch-storage=disk",
}

return {
  -- cmd = default_cmd,
  cmd = function(dispatchers, config, dummy)
    local cmd = vim.deepcopy(default_cmd)
    local root_dir = vim.fs.root(0, root_markers) or vim.uv.cwd()
    root_dir = vim.fs.normalize(vim.uv.fs_realpath(root_dir))

    if vim.lsp.log.get_level() <= vim.log.levels.DEBUG then
      table.insert(cmd, "--log=verbose")
    elseif vim.lsp.log.get_level() < vim.log.levels.ERROR then
      table.insert(cmd, "--log=info")
    else
      table.insert(cmd, "--log=error")
    end

    local home = vim.uv.os_homedir()
    local xdg_config_home = vim.env.XDG_CONFIG_HOME
      or vim.fs.joinpath(home, ".config")
    local clangd_config = vim.fs.joinpath("clangd", "clangd_config.yaml")

    local sysname = vim.uv.os_uname().sysname:lower()
    local global_config
    if sysname:match "^windows" then
      global_config =
        vim.fs.joinpath(vim.env.USERPROFILE, "AppData", "Local", clangd_config)
    elseif sysname == "linux" then
      global_config = vim.fs.joinpath(xdg_config_home, clangd_config)
    else
      global_config = vim.fs.joinpath("~/.config/clangd", clangd_config)
    end

    global_config = vim.fs.normalize(global_config)
    local cmake = require "cmake-tools"
    if cmake.is_cmake_project() then
      local build_dir = cmake.get_build_directory()
      if build_dir and build_dir.filename then
        local dir = vim.fn.fnamemodify(build_dir.filename, ":p")
        table.insert(cmd, "--compile-commands-dir=" .. dir)
      end
    end

    if sysname == "linux" then
      table.insert(cmd, "--malloc-trim")
    end

    return dummy and cmd
      or vim.lsp.rpc.start(cmd, dispatchers, config or { cwd = root_dir })
  end,
  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
    "cuda",
    "proto",
  },
  init_options = {
    -- clangdFileStatus = true,
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
  root_markers = root_markers,
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  on_attach = function()
    vim.keymap.set(
      "n",
      "<leader>ll",
      "<cmd>ClangdSwitchSourceHeader<cr>",
      { desc = "Switch Source/Header (C/C++)", buffer = 0 }
    )

    vim.keymap.set(
      "n",
      "<leader>lA",
      "<cmd>ClangdAST<cr>",
      { desc = "AST toggle (C/C++)", buffer = 0 }
    )

    vim.keymap.set(
      "n",
      "<leader>ui",
      "<cmd>ClangdToggleInlayHints<cr>",
      { desc = "LSP Toggle Inlay Hints (C/C++)", buffer = 0 }
    )
  end,
}

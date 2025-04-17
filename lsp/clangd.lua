-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/clangd.lua

return {
  cmd = {
    "clangd",
    "--all-scopes-completion",
    "--clang-tidy",
    "--header-insertion=never",
    "--completion-style=detailed", -- or bundled
    "--header-insertion=iwyu",
    "--function-arg-placeholders",
    "--enable-config", -- uses ~/.local/clangd/config.yaml
    -- "--query-driver=/usr/bin/clang++,/usr/bin/g++",
    -- clangd performance
    "-j=16",
    "--malloc-trim",
    "--background-index",
    "--pch-storage=memory", -- increases memory usage but improves performance, memory, disk
    -- stash
    -- "--cross-file-rename", got removed? without explanation?!
    -- "--rename-file-limit=400",
  },
  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
  },
  root_markers = {
    ".git",
    ".clangd",
    ".clang-tidy",
    ".clang-format",
  },
  single_file_support = true,
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  init_options = {
    usePlaceholders = true,
    clangdFileStatus = true,
    -- completeUnimported = true,
  },
  -- https://github.com/neovim/neovim/issues/32287
  -- on_new_config = function(new_config, new_cwd)
  --   local status, cmake = pcall(require, "cmake-tools")
  --   if status then
  --     cmake.clangd_on_new_config(new_config)
  --   end
  -- end,

  -- https://raw.githubusercontent.com/clangd/vscode-clangd/master/package.json
  settings = {
    clangd = {
      serverCompletionRanking = false,
    },
  },
}


-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/clangd.lua

local envCc = "COMPILE_CORES"
local nproc = os.getenv(envCc)

local clangd_flags = {
  "--all-scopes-completion",
  "--clang-tidy",
  "--header-insertion=never",
  "--completion-style=detailed",
  "--function-arg-placeholders",
  "--enable-config",
  "--query-driver=/usr/bin/clang++,/usr/bin/g++",
  "--background-index",
  "--pch-storage=memory",
}

if nproc then
  table.insert(clangd_flags, "-j=" .. nproc)
else
  vim.schedule(function()
    vim.notify("env: " .. envCc .. " not found!", vim.log.levels.WARN)
  end)
end

---@type vim.lsp.Config
return {
  cmd = vim.list_extend({ "clangd" }, clangd_flags),
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { ".git", ".clangd", ".clang-tidy", ".clang-format" },
  single_file_support = true,
  capabilities = {
    textDocument = {
      completion = { editsNearCursor = true },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  init_options = {
    usePlaceholders = true,
    clangdFileStatus = true,
  },
  settings = {
    clangd = { serverCompletionRanking = false },
  },

  reuse_client = function(client, config)
    if package.loaded["cmake-tools"] then
      local cmake = require "cmake-tools"
      if cmake.is_cmake_project() then
        local build_dir = cmake.get_build_directory()
        if build_dir and build_dir.filename then
          local dir = vim.fn.fnamemodify(build_dir.filename, ":p")
          config.cmd = vim.list_extend(
            { "clangd" },
            vim.list_extend(clangd_flags, {
              "--compile-commands-dir=" .. dir,
            })
          )
        end
      end
    end
    return client.name == "clangd" -- reuse if same server
  end,
}

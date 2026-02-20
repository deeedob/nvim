-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/lua_ls.lua

local function lazydev_settings(bufnr)
  -- Find workspace for this buffer and let lazydev compute effective settings
  local ok_ws, Workspace = pcall(require, "lazydev.workspace")
  if not ok_ws then
    return {}
  end

  local ws = Workspace.find({ buf = bufnr })
  if not ws then
    return {}
  end

  -- Ensure settings are updated (fills runtime/workspace/library/etc)
  ws:update()

  -- These are the full settings lazydev wants to apply
  return ws.settings or {}
end

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  root_dir = function(bufnr, on_dir)
    local ok, lazydev = pcall(require, "lazydev")
    if ok then
      return on_dir(lazydev.find_workspace(bufnr))
    end
    on_dir(vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
  end,

  on_attach = function(client, bufnr)
    local ld = lazydev_settings(bufnr)
    if next(ld) ~= nil then
      client.settings = vim.tbl_deep_extend("force", client.settings or {}, ld)
      client:notify("workspace/didChangeConfiguration", { settings = client.settings })
    end
  end,

  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
}

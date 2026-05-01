-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/qmlls.lua

local function expand(path)
  return (path:gsub("^~", vim.env.HOME))
end

local function qml_flags_from_prefix_path(prefix_path)
  local import_dirs = {}
  local doc_dir = nil
  for entry in prefix_path:gmatch("[^;]+") do
    local base = expand(entry:gsub("/+$", ""))
    local qml = base .. "/qml"
    if vim.fn.isdirectory(qml) == 1 then
      import_dirs[#import_dirs + 1] = qml
    end
    if not doc_dir then
      local doc = base .. "/doc"
      if vim.fn.isdirectory(doc) == 1 then
        doc_dir = doc
      end
    end
  end
  return import_dirs, doc_dir
end

local function prefix_path_from_presets(preset_name)
  local cwd = vim.fn.getcwd()
  for _, filename in ipairs({ "CMakeUserPresets.json", "CMakePresets.json" }) do
    local path = cwd .. "/" .. filename
    if vim.fn.filereadable(path) == 1 then
      local ok, decoded = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
      if ok and decoded and decoded.configurePresets then
        local map = {}
        for _, p in ipairs(decoded.configurePresets) do
          map[p.name] = p
        end

        local function resolve(name, visited)
          if not name or visited[name] then return nil end
          visited[name] = true
          local p = map[name]
          if not p then return nil end
          local cv = p.cacheVariables
          if cv and cv.CMAKE_PREFIX_PATH then
            return cv.CMAKE_PREFIX_PATH
          end
          local parents = type(p.inherits) == "table" and p.inherits
            or (p.inherits and { p.inherits } or {})
          for _, parent in ipairs(parents) do
            local result = resolve(parent, visited)
            if result then return result end
          end
        end

        local prefix_path = resolve(preset_name, {})
        if prefix_path then return prefix_path end
      end
    end
  end
end

local function project_import_dirs(build_root)
  local seen = {}
  local dirs = {}

  -- find all qmldir files, but skip Qt's own installed ones
  local handle = io.popen(
    string.format("find %q -name qmldir -not -path '*/CMakeFiles/*' 2>/dev/null", build_root)
  )
  if not handle then return dirs end

  for qmldir_path in handle:lines() do
    -- Read the module URI from the qmldir file (line: "module Foo.Bar")
    local uri = nil
    for line in io.lines(qmldir_path) do
      uri = line:match("^module%s+(%S+)")
      if uri then break end
    end
    if uri then
      -- Count URI segments: "ddob.hotline" → 2, "ChopperModule" → 1
      local segments = 0
      for _ in uri:gmatch("[^.]+") do segments = segments + 1 end

      -- Walk up `segments` directories from the qmldir's directory
      local dir = vim.fn.fnamemodify(qmldir_path, ":h") -- strip /qmldir
      for _ = 1, segments do
        dir = vim.fn.fnamemodify(dir, ":h")
      end

      if not seen[dir] then
        seen[dir] = true
        dirs[#dirs + 1] = dir
      end
    end
  end
  handle:close()
  return dirs
end

return {
  cmd = function(dispatchers, config)
    local cmd = { "qmlls" }

    local cmake = vim.F.npcall(require, "cmake-tools")
    if cmake and cmake.is_cmake_project() then
      local build_dir = cmake.get_build_directory()
      if build_dir and build_dir.filename then
        local resolved = vim.fn.resolve(vim.fn.fnamemodify(build_dir.filename, ":p"))

        -- Pass the build dir so qmlls can run cmake to update module info
        -- vim.list_extend(cmd, { "--build-dir", resolved })

        -- Scan the build tree for project qmldir files and derive import roots
        for _, dir in ipairs(project_import_dirs(resolved)) do
          vim.list_extend(cmd, { "-I", dir })
        end
      end

      -- Qt prefix: import paths (-I) and doc path (-d) from CMAKE_PREFIX_PATH
      local preset_name = cmake.get_configure_preset()
      if preset_name then
        local prefix_path = prefix_path_from_presets(preset_name)
        if prefix_path then
          local import_dirs, doc_dir = qml_flags_from_prefix_path(prefix_path)
          for _, dir in ipairs(import_dirs) do
            vim.list_extend(cmd, { "-I", dir })
          end
          if doc_dir then
            vim.list_extend(cmd, { "-d", doc_dir })
          end
        end
      end
    end

    -- print(vim.inspect(cmd))
    return vim.lsp.rpc.start(cmd, dispatchers, config)
  end,

  reuse_client = function(client, config)
    return client.name == config.name
  end,

  filetypes = { "qml", "qmljs" },
  root_markers = {
    ".git",
    ".qmlls.ini",
    "CMakePresets.json",
  },
  single_file_support = true,
}

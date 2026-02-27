local function visual_line_range()
  -- returns (from, to) line numbers (1-indexed)
  local a = vim.fn.getpos("v")[2]
  local b = vim.fn.getpos(".")[2]
  if a > b then
    a, b = b, a
  end
  return a, b
end

local function get_visual_text()
  -- returns selected text lines (best-effort, works for char/linewise)
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return {}
  end
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
  if srow == 0 or erow == 0 then
    return {}
  end

  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end

  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then
    return {}
  end

  if mode == "v" then
    lines[#lines] = string.sub(lines[#lines], 1, ecol)
    lines[1] = string.sub(lines[1], scol + 1)
  end
  return lines
end

local function branches_for_code()
  -- visual: search snippet with git log -S (first commit introducing snippet)
  -- normal: blame current line and use its commit
  local commit = nil
  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" or mode == "\22" then
    local snippet_lines = get_visual_text()
    local snippet = table.concat(snippet_lines, "\n")
    if snippet == "" then
      vim.notify("No snippet selected!", vim.log.levels.WARN)
      return
    end
    local log_cmd = "git log -S"
      .. vim.fn.shellescape(snippet)
      .. " --pretty=format:%H --reverse | head -n1"
    commit = vim.fn.system(log_cmd):gsub("%s+", "")
    if commit == "" then
      vim.notify("Snippet not found in history!", vim.log.levels.WARN)
      return
    end
  else
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then
      vim.notify("No file found!", vim.log.levels.WARN)
      return
    end
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local blame_cmd = "git blame -L "
      .. line
      .. ","
      .. line
      .. " --porcelain "
      .. vim.fn.shellescape(filepath)
    local blame_output = vim.fn.systemlist(blame_cmd)
    if vim.v.shell_error ~= 0 or #blame_output == 0 then
      vim.notify("Could not retrieve blame info", vim.log.levels.WARN)
      return
    end
    commit = (blame_output[1] or ""):match("^(%w+)")
    if not commit then
      vim.notify("Could not parse commit hash", vim.log.levels.WARN)
      return
    end
  end

  local branches = vim.fn.systemlist("git branch -a --contains " .. commit)
  if vim.v.shell_error ~= 0 or #branches == 0 then
    vim.notify("No branches found for commit " .. commit, vim.log.levels.WARN)
    return
  end

  for i, br in ipairs(branches) do
    br = br:gsub("^%s*", ""):gsub("%s*$", ""):gsub("^%*", "")
    branches[i] = br
  end

  local fzf_lua = require("fzf-lua")
  local actions = require("fzf-lua.actions")

  -- show branches in fzf; default action copies branch name + notifies
  fzf_lua.fzf_exec(branches, {
    prompt = "Branches for " .. commit:sub(1, 8) .. "> ",
    preview = "echo {} && echo && git log --oneline --decorate -n 40 {} 2>/dev/null",
    actions = {
      -- enter: copy branch to + and print
      ["default"] = function(selected)
        local br = selected[1]
        if not br or br == "" then
          return
        end
        pcall(vim.fn.setreg, "+", br)
        vim.notify("Copied branch: " .. br)
      end,

      -- ctrl-l: open commits picker for the branch (quick drill-down)
      ["ctrl-l"] = function(selected)
        local br = selected[1]
        if not br or br == "" then
          return
        end
        fzf_lua.fzf_exec("git log --oneline --decorate " .. vim.fn.shellescape(br), {
          prompt = "Commits " .. br .. "> ",
          preview = "git show --color=always {1} | sed -n '1,200p'",
          actions = {
            ["default"] = function(sel)
              local hash = (sel[1] or ""):match("^(%w+)")
              if hash then
                pcall(vim.fn.setreg, "+", hash)
                vim.notify("Copied commit: " .. hash)
              end
            end,
            ["ctrl-y"] = actions.copy_to_clipboard,
          },
        })
      end,
    },
  })
end

local function git_bcommits_range()
  local fzf = require("fzf-lua")
  local actions = require("fzf-lua.actions")

  local abs = vim.fn.expand("%:p")
  if abs == "" then
    vim.notify("No file found!", vim.log.levels.WARN)
    return
  end

  local from, to = visual_line_range()

  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    vim.notify("Not in a git repo", vim.log.levels.WARN)
    return
  end

  -- Prefer tracked relpath
  local rel = vim.fn.systemlist(
    ("git -C %s ls-files --full-name -- %s"):format(
      vim.fn.shellescape(root),
      vim.fn.shellescape(abs)
    )
  )[1]
  if vim.v.shell_error ~= 0 or not rel or rel == "" then
    -- fallback relpath
    rel = vim.fn.systemlist(
      ("python3 - <<'PY'\nimport os\nroot=%q\nabs=%q\nprint(os.path.relpath(abs, root))\nPY"):format(
        root,
        abs
      )
    )[1]
  end

  local pretty = [[%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset]]

  local cmd = [[git log --no-patch --color --pretty=format:"]]
    .. pretty
    .. [[" -L ]]
    .. tostring(from)
    .. ","
    .. tostring(to)
    .. ":"
    .. vim.fn.shellescape(rel)

  fzf.fzf_exec(cmd, {
    cwd = root,
    prompt = ("BCommits %d-%d❯ "):format(from, to),

    -- This matches how fzf-lua git pickers behave (ANSI + hash as first token)
    fzf_opts = { ["--ansi"] = "" },

    -- Same preview idea as fzf-lua bcommits
    preview = "git show --color {1} -- " .. vim.fn.shellescape(rel),

    actions = {
      ["enter"] = actions.git_buf_edit,
      ["ctrl-s"] = actions.git_buf_split,
      ["ctrl-v"] = actions.git_buf_vsplit,
      ["ctrl-t"] = actions.git_buf_tabedit,
      ["ctrl-y"] = { fn = actions.git_yank_commit, exec_silent = true },
    },
  })
end

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = function()
      local function fzf(fn, opts)
        return function()
          local o = opts
          if type(opts) == "function" then
            o = opts()
          end
          require("fzf-lua")[fn](o)
        end
      end

      return {
        -- Files
        {
          "<leader>ff",
          function()
            require("fzf-lua").files({
              prompt = "Files❯ ",
              fzf_opts = {
                ["--scheme"] = "path",
                ["--tiebreak"] = "chunk,length,index",
              },
            })
          end,
          desc = "FzfLua: Files",
        },
        {
          "<leader>fF",
          fzf("files", function()
            return { cwd = vim.fn.expand("%:p:h") }
          end),
          desc = "FzfLua: Files (cwd = file dir)",
        },
        -- config pickers
        {
          "<leader>fc",
          fzf("files", { cwd = vim.fn.stdpath("config") }),
          desc = "FzfLua: Config files (user)",
        },
        {
          "<leader>fC",
          fzf("files", { cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }),
          desc = "FzfLua: Config files (lazy dir)",
        },

        -- Buffers / lines
        { "<leader>fb", fzf("buffers"), desc = "FzfLua: Buffers" },
        { "<leader>f/", fzf("blines"), desc = "FzfLua: Buffer lines" },
        { "<leader>f?", fzf("lines"), desc = "FzfLua: All open buffer lines" },

        -- Search
        {
          "<leader>fg",
          fzf("live_grep"),
          desc = "FzfLua: Live grep (project)",
        },
        {
          "<leader>fG",
          fzf("live_grep", function()
            return { cwd = vim.fn.expand("%:p:h") }
          end),
          desc = "FzfLua: Live grep (file dir)",
        },
        {
          "<leader>fw",
          fzf("grep_cword"),
          desc = "FzfLua: Grep word under cursor",
        },
        {
          "<leader>fw",
          fzf("grep_visual"),
          mode = "v",
          desc = "FzfLua: Grep visual selection",
        },

        -- Help / commands / keymaps
        { "<leader>fh", fzf("help_tags"), desc = "FzfLua: Help tags" },
        { "<leader>f:", fzf("commands"), desc = "FzfLua: Commands" },
        { "<leader>fk", fzf("keymaps"), desc = "FzfLua: Keymaps" },

        -- Diagnostics (Neovim + LSP)
        {
          "<leader>fd",
          fzf("diagnostics_document"),
          desc = "FzfLua: Diagnostics (buffer)",
        },
        {
          "<leader>fD",
          fzf("diagnostics_workspace"),
          desc = "FzfLua: Diagnostics (workspace)",
        },

        -- LSP symbols
        {
          "<leader>fs",
          fzf("lsp_document_symbols"),
          desc = "FzfLua: Document symbols",
        },
        {
          "<leader>fS",
          fzf("lsp_workspace_symbols"),
          desc = "FzfLua: Workspace symbols",
        },

        {
          "<leader>fz",
          fzf("zoxide"),
          desc = "Zoxide: cd + files",
        },

        {
          "<leader>lh",
          function()
            local actions = require("fzf-lua.actions")
            require("fzf-lua").lsp_definitions({
              jump1 = true,
              jump1_action = actions.file_split, -- single result
              actions = { ["default"] = actions.file_split }, -- multi result (enter)
            })
          end,
          desc = "LSP: Definition (split)",
        },
        {
          "<leader>lv",
          function()
            local actions = require("fzf-lua.actions")
            require("fzf-lua").lsp_definitions({
              jump1 = true,
              jump1_action = actions.file_vsplit, -- single result
              actions = { ["default"] = actions.file_vsplit }, -- multi result (enter)
            })
          end,
          desc = "LSP: Definition (vsplit)",
        },

        -- Git
        -- { "<leader>gs", fzf "git_status", desc = "FzfLua: Git status" },
        -- { "<leader>gb", fzf "git_branches", desc = "FzfLua: Git branches" },
        {
          "<leader>gc",
          fzf("git_commits"),
          desc = "FzfLua: Git commits (repo)",
        },
        {
          "<leader>gC",
          fzf("git_bcommits"),
          desc = "FzfLua: Git commits (buffer)",
        },
        {
          "<leader>gc",
          git_bcommits_range,
          mode = "v",
          desc = "Git: Buffer commits (selected range)",
        },
        {
          "<leader>gb",
          branches_for_code,
          mode = { "n", "v" },
          desc = "Git: Branches containing code/commit",
        },

        -- Quality-of-life
        { "<leader>fr", fzf("resume"), desc = "FzfLua: Resume last picker" },
        { "<leader>fR", fzf("oldfiles"), desc = "FzfLua: Recent files" },
        { "<leader>fB", fzf("builtin"), desc = "FzfLua: Builtins" },
      }
    end,

    opts = function()
      local actions = require("fzf-lua.actions")
      require("fzf-lua").register_ui_select({
        winopts = {
          height = 0.35,
          width = 0.55,
          row = 0.50,
          col = 0.50,
        },
      })

      return {
        winopts = {
          height = 0.85,
          width = 0.90,
          row = 0.35,
          col = 0.50,
          preview = {
            layout = "flex",
            vertical = "down:50%",
            horizontal = "right:60%",
            flip_columns = 140,
          },
        },

        keymap = {
          builtin = {
            true,
            -- ["<Esc>"] = "hide", -- make Esc hide (resume-able) instead of hard-abort
          },
          fzf = {
            true,
          },
        },

        actions = {
          files = {
            true,
          },
        },

        files = {
          hidden = true,
        },

        grep = {
          hidden = true,
          actions = {
            ["ctrl-g"] = { actions.grep_lgrep },
            ["ctrl-r"] = { actions.toggle_ignore },
          },
        },

        fzf_colors = true,
      }
    end,
  },
}

vim.filetype.add({
  extension = {
    vert = "glsl",
    frag = "glsl",
    nginx = "nginx",
    conf = "dosini",
    log = "log",
    ini = "toml",
    gotmpl = "gotmpl",
  },

  filename = {
    [".gitconfig"] = ".gitconfig",
    ["gitconfig"] = "gitconfig",
    [".editorconfig"] = vim.version.ge(vim.version(), { 0, 9 }) and "editorconfig" or "dosini",
    [".flake8"] = "toml",
    ["flake8"] = "toml",
    [".bashrc"] = "sh",
    [".profile"] = "sh",
    ["config.txt"] = "dosini",
    ["nginx.conf"] = "nginx",
    ["tmux.conf"] = "tmux",
    ["zsh.sh"] = "zsh",
    ["clang-format"] = "yaml",
    ["clang-tidy"] = "yaml",
  },

  pattern = {
    [".*/etc/nginx/.*"] = "nginx",
    ["config%.txt"] = "dosini",
    ["%.bash_.*"] = "sh",
    ["%.bashrc%..*"] = "sh",
    [".*/layouts/_partials/.*%.html"] = "gotmpl",
    [".*/zfunctions/.*"] = "zsh",
    [".*"] = {
      priority = -math.huge,
      function(_, bufnr)
        local shebang = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
        if shebang then
          local nvim_path = vim.pesc(vim.v.progpath)
          local nvim_env_regex =
            vim.regex([[^#!\(env\|/usr/bin/env\|/bin/env\)\s\+\(\(-S\)\s\+\)\?\<nvim\>]])
          if shebang:match(("^#!%s"):format(nvim_path)) or nvim_env_regex:match_str(shebang) then
            return "lua"
          end
        end
      end,
    },
  },
})


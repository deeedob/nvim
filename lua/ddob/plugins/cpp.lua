return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = {
      inlay_hints = { inline = false },
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
  },

  {
    "gauteh/vim-cppman",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    config = function()
      vim.keymap.set("n", "<leader>cDk", function()
        local word = vim.fn.expand "<cword>"
        local escaped_word = vim.fn.fnameescape(word)
        vim.cmd("Cppman " .. escaped_word)
      end, { desc = "Open cppman with cword" })
    end,
  },

  {
    "Civitasv/cmake-tools.nvim",
    init = function()
      local local_cmake = "CMakeLists.txt"
      -- async determine a possible project dir
      vim.uv.fs_stat(local_cmake, function(_, stat)
        --  Check current dir for a CMakeLists.txt
        if stat then
          local file = io.open(local_cmake, "r")
          if file then
            local content = file:read "*all"
            file:close()
            if content:find "project%s*%(" then
              vim.schedule(function()
                require "ddob.cmake-tools"
              end)
            end
          end
        end
        -- CWD doesn't have a valid CMakeLists.txt. Search the project root
        local project_root = require("ddob.utils").find_project_root()
        if project_root then
          local proj = vim.uv.fs_stat(project_root .. "/CMakeLists.txt")
          if proj then
            -- We expect that this CMakeLists.txt file in root is already valid
            vim.schedule(function()
              require "ddob.cmake-tools"
              require("cmake-tools").select_cwd(proj)
            end)
          end
        end
      end)
      return true
    end,
    keys = {
      { "<leader>cg", ":CMakeGenerate<CR>", desc = "CMake Configure" },
      { "<leader>cb", ":CMakeBuild<CR>", desc = "CMake Build" },
      { "<leader>cr", ":CMakeRun<CR>", desc = "CMake Run" },
      { "<leader>cd", ":CMakeDebug<CR>", desc = "CMake Debug" },

      { "<leader>cG", ":CMakeGenerate!<CR>", desc = "CMake Force Configure" },
      { "<leader>cB", ":CMakeBuild!<CR>", desc = "CMake Force Build" },
      { "<leader>cR", ":CMakeQuickRun<CR>", desc = "CMake Quick Run" },
      { "<leader>cD", ":CMakeQuickDebug<CR>", desc = "CMake Quick Debug" },

      { "<leader>ck", ":CMakeStop<CR>", desc = "CMake Kill" },
      { "<leader>cc", ":CMakeClean<CR>", desc = "CMake Clean" },

      {
        "<leader>csr",
        ":CMakeSelectLaunchTarget<CR>",
        desc = "CMake Select Run Target",
      },
      {
        "<leader>csb",
        ":CMakeSelectBuildTarget<CR>",
        desc = "CMake Select Build Target",
      },
      {
        "<leader>cst",
        ":CMakeSelectBuildType<CR>",
        desc = "CMake Select Build Type",
      },
      { "<leader>csk", ":CMakeSelectKit<CR>", desc = "CMake Select Kit" },
      {
        "<leader>csf",
        ":CMakeShowTargetFiles<CR>",
        desc = "CMake Show Target's files",
      },
      { "<leader>css", ":CMakeSettings<CR>", desc = "CMake Project Settings" },
      {
        "<leader>csc",
        ":CMakeSelectConfigurePreset<CR>",
        desc = "CMake Configure Preset",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}

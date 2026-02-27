return {
  "Civitasv/cmake-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  ft = { "cmake", "c", "cpp", "objc", "objcpp" },
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
  config = function()
    vim.api.nvim_create_user_command("CMakeWipe", function()
      local build_dir = require("cmake-tools").get_build_directory()
      if build_dir then
        local cmd = "rm -rf " .. build_dir.filename
        print(cmd)
        vim.fn.system(cmd)
      end
      vim.cmd([[CMakeGenerate]])
    end, { desc = "Wipe build dir and start fresh" })

    vim.keymap.set("n", "<leader>cw", ":CMakeWipe<cr>", { desc = "[w]ipe Build Dir", remap = true })

    local nproc = tonumber(os.getenv("COMPILE_CORES"))

    require("cmake-tools").setup({
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_use_preset = true,
      cmake_regenerate_on_save = false,
      cmake_generate_options = {
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
      },
      cmake_build_options = { "-j " .. tostring(nproc) },
      cmake_build_directory = "cmake-build/${variant:buildType}",
      cmake_compile_commands_options = {
        action = "lsp", -- available options: soft_link, copy, lsp, none
        -- lsp:       this will automatically set compile commands file location using lsp
      },
      cmake_kits_path = vim.fn.stdpath("config") .. "/res/cmake-kits.json",
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
      cmake_executor = {
        name = "toggleterm",
        opts = {
          direction = "horizontal",
          close_on_exit = false,
          auto_scroll = false,
          scroll_on_error = true,
          auto_focus = false,
          focus_on_error = false,
          singleton = true,
        },
      },
      cmake_runner = {
        name = "toggleterm",
        opts = {
          direction = "horizontal",
          close_on_exit = false,
          auto_scroll = false,
          scroll_on_error = true,
          auto_focus = false,
          focus_on_error = true,
          singleton = true,
        },
      },
      cmake_notifications = {
        runner = { enabled = false },
        executor = { enabled = false },
      },
      cmake_virtual_text_support = false,
      cmake_use_scratch_buffer = false,
    })
  end,
}

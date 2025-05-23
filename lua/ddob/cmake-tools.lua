-- Toggle List Characters Command
vim.api.nvim_create_user_command("CMakeWipe", function()
  local build_dir = require("cmake-tools").get_build_directory()
  if build_dir then
    local cmd = "rm -rf " .. build_dir.filename
    print(cmd)
    vim.fn.system(cmd)
  end
  vim.cmd [[CMakeGenerate]]
end, { desc = "Wipe build dir and start fresh" })

vim.keymap.set(
  "n",
  "<leader>cw",
  ":CMakeWipe<cr>",
  { desc = "[w]ipe Build Dir", remap = true }
)

local nproc = tonumber(io.popen("nproc"):read "*n") - 1

require("cmake-tools").setup {
  cmake_command = "cmake",
  ctest_command = "ctest",
  cmake_use_preset = true,
  cmake_regenerate_on_save = false,
  cmake_generate_options = {
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
    "-DQT_QML_GENERATE_QMLLS_INI=1",
  },
  cmake_build_options = { "-j " .. tostring(nproc) },
  cmake_build_directory = "cmake-build/${variant:buildType}",
  cmake_soft_link_compile_commands = true,
  cmake_compile_commands_from_lsp = false,
  cmake_kits_path = vim.fn.stdpath "config" .. "/res/cmake-kits.json",
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
}

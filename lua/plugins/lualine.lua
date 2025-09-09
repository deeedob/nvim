return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    local icons = {
      cmake = {
        Build = "󱌣",
        Arch = "",
        Run = "",
        Gear = "",
      },
    }

    local col = "#928374"
    local hide_cmake = 80

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand "%:t") ~= 1
      end,
      min_window_width = function(width)
        return vim.fn.winwidth(0) > width
      end,
    }

    -- local cmake = require("cmake-tools")
    local cmake = nil
    local function check_cmake()
      if package.loaded["cmake-tools"] then
        cmake = require "cmake-tools"
      end
    end

    local ext_cmake = {
      build_target = {
        function()
          if not cmake then
            return ""
          end
          local b_target = cmake.get_build_target()
          return (b_target and b_target or "X")
        end,
        cond = function()
          if not cmake then
            check_cmake()
            return false
          end
          return conditions.min_window_width(hide_cmake)
            and cmake.is_cmake_project()
        end,
        icon = icons.cmake.Gear,
        color = { fg = col },
        on_click = function(n, mouse)
          if n == 1 then
            if mouse == "l" then
              vim.cmd "CMakeSelectBuildTarget"
            end
          end
        end,
      },
      launch_target = {
        function()
          if not cmake then
            return ""
          end
          local l_target = cmake.get_launch_target()
          return (l_target and l_target or "X")
        end,
        icon = icons.cmake.Run,
        cond = function()
          if not cmake then
            return false
          end
          return conditions.min_window_width(hide_cmake)
            and cmake.is_cmake_project()
        end,
        color = { fg = col },
        on_click = function(n, mouse)
          if n == 1 then
            if mouse == "l" then
              vim.cmd "CMakeSelectLaunchTarget"
            end
          end
        end,
      },
      kits = {
        function()
          if not cmake then
            return ""
          end
          local kit = cmake.get_kit()
          return (kit and kit or "X")
        end,
        icon = icons.cmake.Arch,
        cond = function()
          if not cmake then
            return false
          end
          return conditions.min_window_width(hide_cmake)
            and cmake.is_cmake_project()
            and not cmake.has_cmake_preset()
        end,
        color = { fg = col },
        on_click = function(n, mouse)
          if n == 1 then
            if mouse == "l" then
              vim.cmd "CMakeSelectKit"
            end
          end
        end,
      },
      configure_preset = {
        function()
          if not cmake then
            return ""
          end
          local c_preset = cmake.get_configure_preset()
          return (c_preset and c_preset or "X")
        end,
        icon = icons.cmake.Build,
        cond = function()
          if not cmake then
            return false
          end
          return conditions.min_window_width(hide_cmake)
            and cmake.is_cmake_project()
            and cmake.has_cmake_preset()
        end,
        color = { fg = col },
        on_click = function(n, mouse)
          if n == 1 then
            if mouse == "l" then
              vim.cmd "CMakeSelectConfigurePreset"
            end
          end
        end,
      },
      build_type = {
        function()
          if not cmake then
            return ""
          end
          local type = cmake.get_build_type()
          return " " .. (type and type or "")
        end,
        icon = icons.cmake.Build,
        cond = function()
          if not cmake then
            return false
          end
          return conditions.min_window_width(hide_cmake)
            and cmake.is_cmake_project()
            and not cmake.has_cmake_preset()
        end,
        color = { fg = col },
        on_click = function(n, mouse)
          if n == 1 then
            if mouse == "l" then
              vim.cmd "CMakeSelectBuildType"
            end
          end
        end,
      },
      build_preset = {
        function()
          check_cmake()
          if not cmake then
            return ""
          end
          local b_preset = cmake.get_build_preset()
          return (b_preset and b_preset or "X")
        end,
        cond = function()
          if not cmake then
            return false
          end
          return conditions.min_window_width(hide_cmake)
            and cmake.is_cmake_project()
            and cmake.has_cmake_preset()
        end,
        color = { fg = col },
        on_click = function(n, mouse)
          if n == 1 then
            if mouse == "l" then
              vim.cmd "CMakeSelectBuildPreset"
            end
          end
        end,
      },
    }

    require("lualine").setup {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
        always_divide_middle = false,
      },
      -- extensions = { "toggleterm", "fugitive", "nvim-dap-ui", "trouble", "lazy" },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          ext_cmake.build_target,
          ext_cmake.launch_target,
          {
            "%=",
            cond = function()
              return conditions.min_window_width(60)
            end,
          },
        },
        lualine_x = {
          ext_cmake.kits,
          ext_cmake.configure_preset,
          ext_cmake.build_type,
          ext_cmake.build_preset,
        },
        lualine_y = {
          {
            function()
              local clients = vim.lsp.get_clients()
              if #clients == 1 then
                return clients[1].name
              else
                return " " .. #clients .. " LSP"
              end
            end,
            icon = "",
            color = { gui = "bold" },
            cond = function()
              return conditions.min_window_width(60)
            end,
          },
          {
            "diagnostics",
          },
          {
            "diff",
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_z = {
          { "location" },
          -- { "progress" },
        },
      },
    }
  end,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}

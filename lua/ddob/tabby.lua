vim.o.showtabline = 2

require("scope").setup {}

local highlights = require "tabby.module.highlight"

local theme = {
  head = "TabLine",
  tail = "TabLine",

  fill = "TabLineFill",
  win = "TabLineSel",

  current_tab = "TabLineSel",
  tab = "TabLine",
  current_buf = "TabLineSel",
  buf = "TabLine",
  current = "NormalNC"
}

local devicons = require "nvim-web-devicons"

local function ensure_hl_obj(hl)
  if type(hl) == "string" then
    return highlights.extract(hl)
  end
  return hl
end

local sep = function(symbol, cur_hl, back_hl)
  local cur_hl_obj = ensure_hl_obj(cur_hl)
  local back_hl_obj = ensure_hl_obj(back_hl)
  return {
    symbol,
    hl = {
      fg = cur_hl_obj.bg,
      bg = back_hl_obj.bg,
    },
  }
end

local components = function()
  local cwd = " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
  local coms = {
    {
      type = "text",
      text = {
        cwd,
        hl = theme.head,
      },
    },
    {
      type = "text",
      text = sep("", theme.head, theme.fill),
    },
  }

  -- Tab setup
  local tabs = vim.api.nvim_list_tabpages()
  local current_tab = vim.api.nvim_get_current_tabpage()
  for _, tabid in ipairs(tabs) do
    local hl = theme.tab
    if tabid == current_tab then
      hl = theme.current_tab
    end
    table.insert(coms, {
      type = "text",
      text = sep("", hl, theme.fill),
    })
    table.insert(coms, {
      type = "tab",
      tabid = tabid,
      label = {
        "  " .. vim.api.nvim_tabpage_get_number(tabid) .. "  ",
        hl = hl,
      },
    })
    table.insert(coms, {
      type = "text",
      text = sep("", hl, theme.fill),
    })
  end
  table.insert(coms, {
    type = "text",
    text = {
      " ",
      hl = theme.fill,
    },
  })
  table.insert(coms, { type = "spring" })

  -- Current buffer
  local cur_bufid = vim.api.nvim_get_current_buf()
  table.insert(coms, {
    type = "text",
    text = {
      vim.fn.expand "%:.", -- get current bufname local to project dir
      hl = theme.current,
    },
  })

  table.insert(coms, {
    type = "text",
    text = {
      " ",
      hl = theme.fill,
    },
  })
  table.insert(coms, { type = "spring" })

  -- Buf setup
  for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufid) and vim.bo[bufid].buflisted then
      local hl = theme.buf
      if bufid == cur_bufid then
        hl = theme.current_buf
      end
      local fname = vim.api.nvim_buf_get_name(bufid)
      local filename = vim.fn.fnamemodify(fname, ":t")
      local ext = vim.fn.fnamemodify(fname, ":e")
      local icon, icon_hl = devicons.get_icon(filename, ext)
      if not icon then
        icon = ""
      end
      icon_hle = ensure_hl_obj(icon_hl)

      table.insert(coms, {
        type = "text",
        text = sep("", hl, theme.fill),
      })
      table.insert(coms, {
        type = "text",
        text = {
          " " .. icon .. " ",
          hl = { fg = icon_hle and icon_hle.fg or "NONE", bg = ensure_hl_obj(hl).bg },
        },
      })
      table.insert(coms, {
        type = "text",
        text = sep("", hl, theme.fill),
      })
    end
  end
  table.insert(coms, {
    type = "text",
    text = sep("", theme.tail, theme.fill),
  })
  table.insert(coms, {
    type = "text",
    text = {
      "   ",
      hl = theme.tail,
    },
  })
  return coms
end

require("tabby").setup {
  components = components,
}

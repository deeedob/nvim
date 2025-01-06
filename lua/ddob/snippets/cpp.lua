local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("cpp", {
  s("scast", fmt("static_cast<{}>({})", { i(1, "type"), i(2, "var") })),
  s("rcast", fmt("reinterpret_cast<{}>({})", { i(1, "type"), i(2, "var") })),
  s("qcon", fmt("QObject::connect({}, {})", { i(1, "type"), i(2, "var") })),
})

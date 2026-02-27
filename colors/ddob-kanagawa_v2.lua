-- ddob-kanagawa
-- Structure: Palette (P) → UI roles (U) + Syntax roles (S) → Syn* categories
--            → Editor / VimSyntax / Treesitter / LSP / Plugins / Lang / Apply
--
-- Const/mutability philosophy:
--   yellow  = constant / readonly / immutable  (same hue as number literals)
--   white   = mutable variable / plain member
--   italic  = abstract / async / parameter
--   strikethrough = deprecated
--   bold    = definition site (function name, type name being declared)

vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd.syntax("reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "ddob-kanagawa"

-- ----------------------------------------------------------------------------
-- Config  (override: vim.g.ddob_kanagawa = { transparent = true, ... })
-- ----------------------------------------------------------------------------
local config = vim.tbl_deep_extend("force", {
  transparent = false,
  dimInactive = true,
  gutter = false,
  italicComments = true,
  undercurl = true,
  overrides = { editor = {}, syn = {}, vim = {}, ts = {}, lsp = {}, plugins = {}, lang = {} },
}, vim.g.ddob_kanagawa or {})

-- ----------------------------------------------------------------------------
-- Palette  (Dragon-Kanagawa — all raw hex lives here only)
-- ----------------------------------------------------------------------------
local P = {
  -- Backgrounds (darkest → lightest)
  black0 = "#0d0c0c",
  black1 = "#12120f",
  black2 = "#1D1C19",
  black3 = "#181616", -- main bg
  black4 = "#282727",
  black5 = "#393836",
  black6 = "#625e5a",

  -- Neutral text
  white = "#c5c9c5", -- base fg
  white_dim = "#C8C093", -- dimmed fg / parameters
  white_warm = "#DCD7BA", -- float fg
  gray_dark = "#7a8382", -- nontext / punctuation special
  gray = "#a6a69c", -- comments
  gray2 = "#9e9b93", -- doc comments, delimiters

  -- Core accent hues
  green = "#87a987", -- string special / bright green
  green2 = "#8a9a7b", -- string literals
  yellow = "#c4b28a", -- constants, numbers, readonly/const ← KEY COLOR
  orange = "#b6927b", -- builtin constants, macros
  orange2 = "#b98d7b", -- operators, keyword.function, include
  red = "#c4746e", -- keywords (if/else/for/…), errors in comments
  blue = "#8ba4b0", -- type names, regex
  teal = "#949fb5", -- labels, math markup
  aqua = "#8ea4a2", -- identifiers, storage class
  violet = "#8992a7", -- general keywords
  violet2 = "#b8b4d0", -- namespaces (brighter)
  pink = "#a292a3", -- builtin functions / types

  -- Special syntax
  wave_aqua4 = "#7AA880", -- type names
  wave_red = "#E46876", -- properties / object access
  surimi = "#D98B4E", -- method names
  carp_yellow = "#E6C384", -- term bright yellow

  -- Float / popup (cooler ink)
  ink2 = "#1a1a22",
  ink5 = "#363646",
  ink6 = "#54546D",
  violet1 = "#938AA9", -- pmenu thumb

  -- Search / selection
  wave_blue1 = "#223249",
  wave_blue2 = "#2D4F67",

  -- Diagnostics / VCS (bright, intentional)
  samurai_red = "#E82424",
  ronin_yellow = "#FF9E3B",
  spring_green = "#98BB6C",
  dragon_blue = "#658594",
  wave_aqua1 = "#6A9589",
  autumn_green = "#76946A",
  autumn_red = "#C34043",
  autumn_yellow = "#DCA561",

  -- Diff backgrounds (subtle, desaturated)
  winter_green = "#2B3328",
  winter_red = "#43242B",
  winter_blue = "#252535",
  winter_yellow = "#49443C",

  -- Extra terminal colors
  wave_aqua2 = "#7AA89F",
}

-- ----------------------------------------------------------------------------
-- UI Roles  (editor chrome only)
-- ----------------------------------------------------------------------------
local U = {
  bg = config.transparent and "NONE" or P.black3,
  bg_dim = P.black1,
  bg_gutter = config.gutter and P.black4 or "NONE",
  bg_visual = P.wave_blue1,
  bg_search = P.wave_blue2,

  fg = P.white,
  fg_dim = P.white_dim,
  fg_reverse = P.wave_blue1,
  fg_nontext = P.black6,
  fg_special = P.gray_dark,

  float_bg = config.transparent and "NONE" or P.ink2,
  float_border = P.ink6,

  pmenu_fg = P.white_warm,
  pmenu_bg = P.ink2,
  pmenu_fg_sel = "NONE",
  pmenu_bg_sel = P.ink5,
  pmenu_bg_sbar = P.ink5,
  pmenu_bg_thumb = P.violet1,

  whitespace = P.black6,
  nontext = P.black6,

  -- Diff backgrounds
  diff_add = P.winter_green,
  diff_delete = P.winter_red,
  diff_change = P.winter_blue,
  diff_text = P.winter_yellow,
  vcs_added = P.autumn_green,
  vcs_removed = P.autumn_red,
  vcs_changed = P.autumn_yellow,
}

-- ----------------------------------------------------------------------------
-- Syntax Roles
-- Const/mutability rule:
--   S.const_val  (yellow) = anything readonly/immutable/constant
--   S.variable   (white)  = anything mutable / plain
-- Changing a color here propagates everywhere via Syn*.
-- ----------------------------------------------------------------------------
local S = {
  -- ── Literals ──────────────────────────────────────────────────────────────
  string = P.green2, -- string literals
  string_escape = P.red, -- \n, \t, …
  string_regex = P.blue, -- /regex/
  string_special = P.green, -- interpolation #{}, symbols, dates
  string_path = P.aqua, -- filenames / paths
  string_url = P.green2, -- hyperlinks (underlined separately)

  -- ── Constants & numbers ───────────────────────────────────────────────────
  -- YELLOW = immutable.  This is the anchor color for the const/readonly split.
  const_val = P.yellow, -- enum members, #define values, readonly vars
  number = P.yellow, -- numeric literals (same hue → "things that don't change")
  boolean = P.orange, -- true/false (builtin constants)
  nil_val = P.orange, -- nil/null/None/nullptr

  -- ── Identifiers & variables ───────────────────────────────────────────────
  -- WHITE = mutable.  Plain identifiers that the user can assign to.
  variable = P.white, -- mutable local/global variable
  variable_const = P.yellow, -- const/let (immutable binding) — LSP readonly
  parameter = P.white_dim, -- function parameters (italic in Syn)
  parameter_const = P.yellow, -- const parameter — LSP readonly modifier
  builtin_var = P.aqua, -- self, this, super, __name__
  namespace = P.violet2, -- module/namespace names
  label = P.teal, -- goto / case labels, heredoc labels

  -- ── Members / fields / properties ─────────────────────────────────────────
  -- Same white/yellow split applies to members:
  field = P.white, -- mutable struct field / object member
  field_const = P.yellow, -- readonly/const field (LSP readonly)
  property = P.wave_red, -- key in key/value, object.property access
  property_const = P.yellow, -- const property (LSP readonly)
  enum_member = P.yellow, -- always constant by definition

  -- ── Functions & methods ───────────────────────────────────────────────────
  func_def = P.yellow, -- function definition name (declaration site)
  func_call = P.white, -- function call (not definition) — stays plain
  func_builtin = P.pink, -- builtin/stdlib functions
  method_def = P.surimi, -- method definition name
  method_call = P.white, -- method call — stays plain
  constructor = P.yellow, -- constructor definition name
  macro = P.orange, -- preprocessor macros / macro invocations
  attribute = P.orange2, -- decorators, annotations, Rust attributes

  -- ── Types ─────────────────────────────────────────────────────────────────
  type_name = P.wave_aqua4, -- type names in usage (int x, Vec<T>, …)
  type_builtin = P.pink, -- primitive builtins (int, bool, str, …)
  type_def = P.yellow, -- the identifier being defined (typedef X ← this)
  struct_name = P.orange2, -- struct/class/record name at definition
  class_name = P.teal, -- class name (slightly different from struct)
  interface_name = P.teal, -- interface / trait name
  enum_name = P.yellow, -- enum name at definition

  -- ── Keywords ──────────────────────────────────────────────────────────────
  keyword = P.violet, -- general keywords
  kw_conditional = P.red, -- if, else, switch, match, ?:
  kw_repeat = P.red, -- for, while, loop, do
  kw_return = P.orange2, -- return, yield, break, continue
  kw_function = P.orange2, -- fn, func, def, fun (the keyword, not name)
  kw_type = P.blue, -- struct, class, enum, interface (type-decl kw)
  kw_modifier = P.aqua, -- const, static, public, mut, volatile, inline
  kw_operator = P.red, -- and, or, not, in, is, as
  kw_exception = P.red, -- throw, catch, try, raise, rescue
  kw_import = P.orange2, -- import, include, use, require, from
  kw_coroutine = P.violet, -- async, await, yield, go
  kw_debug = P.red, -- debugger, breakpoint

  -- ── Preprocessor ──────────────────────────────────────────────────────────
  preproc = P.red, -- #if, #pragma, #line
  preproc_define = P.orange2, -- #define NAME

  -- ── Operators & punctuation ───────────────────────────────────────────────
  operator = P.orange2, -- +, -, *, /, =, …
  delimiter = P.gray2, -- ; . , (slightly dimmed)
  bracket = P.gray2, -- () {} [] (slightly dimmed)
  punct_special = P.gray_dark, -- #{} in interpolation, * in globs

  -- ── Tags (HTML/XML/JSX) ───────────────────────────────────────────────────
  tag_name = P.violet, -- <div>, <Component>
  tag_builtin = P.pink, -- <html>, <body> (builtin html tags)
  tag_attr = P.orange2, -- attribute names
  tag_delim = P.gray2, -- < > / =

  -- ── Comments ──────────────────────────────────────────────────────────────
  comment = P.gray2, -- regular comments
  comment_doc = P.gray, -- /** doc */ comments
  comment_todo = P.pink, -- TODO text (bg set in Syn)
  comment_note = P.dragon_blue, -- NOTE/INFO
  comment_warn = P.ronin_yellow, -- WARNING/HACK
  comment_error = P.samurai_red, -- ERROR/FIXME/DEPRECATED

  -- ── Diagnostics ───────────────────────────────────────────────────────────
  error = P.samurai_red,
  warning = P.ronin_yellow,
  info = P.dragon_blue,
  hint = P.wave_aqua1,
  ok = P.spring_green,
}

-- ----------------------------------------------------------------------------
-- Syn*  — one named group per semantic concept.
-- Registered as "Syn<Name>" so everything downstream just links.
-- Edit here to retheme; nothing else needs touching.
-- ----------------------------------------------------------------------------
local Syn = {
  -- ── Comments ──────────────────────────────────────────────────────────────
  Comment = { fg = S.comment, italic = config.italicComments },
  CommentDocumentation = { fg = S.comment_doc, italic = config.italicComments },
  CommentTodo = { fg = P.black3, bg = S.info, bold = true },
  CommentNote = { fg = S.comment_note, italic = config.italicComments },
  CommentWarning = { fg = S.comment_warn, italic = config.italicComments },
  CommentError = { fg = S.comment_error, italic = config.italicComments },

  -- ── Strings ───────────────────────────────────────────────────────────────
  String = { fg = S.string },
  StringEscape = { fg = S.string_escape, italic = true },
  StringRegex = { fg = S.string_regex },
  StringSpecial = { fg = S.string_special }, -- interpolation, symbols
  StringPath = { fg = S.string_path, underline = true },
  StringUrl = { fg = S.string_url, underline = true },
  Character = { fg = S.string },

  -- ── Constants & numbers ───────────────────────────────────────────────────
  -- All yellow → visually groups "things that don't change"
  Constant = { fg = S.const_val }, -- named constants
  Number = { fg = S.number },
  Float = { fg = S.number },
  Boolean = { fg = S.boolean, bold = true },
  Nil = { fg = S.nil_val }, -- nil/null/None

  -- ── Variables — mutable (white) vs const/readonly (yellow) ────────────────
  Variable = { fg = S.variable }, -- plain mutable var
  VariableConst = { fg = S.variable_const }, -- const/let/readonly binding
  VariableBuiltin = { fg = S.builtin_var, italic = true }, -- self, this, __file__
  Parameter = { fg = S.parameter, italic = true }, -- function params
  ParameterConst = { fg = S.parameter_const, italic = true }, -- const param

  -- ── Members — mutable (white) vs const (yellow) ───────────────────────────
  Field = { fg = S.field }, -- mutable struct field
  FieldConst = { fg = S.field_const }, -- readonly / const field
  Property = { fg = S.property }, -- key in key/value pair
  PropertyConst = { fg = S.property_const }, -- const property
  EnumMember = { fg = S.enum_member }, -- always const by nature

  -- ── Namespaces / modules / labels ─────────────────────────────────────────
  Namespace = { fg = S.namespace, italic = true },
  Label = { fg = S.label },

  -- ── Functions — definition (yellow/surimi) vs call (plain white) ──────────
  Function = { fg = S.func_def }, -- definition site
  FunctionCall = { fg = S.func_call }, -- call site (plain)
  FunctionBuiltin = { fg = S.func_builtin, italic = true },
  Method = { fg = S.method_def }, -- definition site
  MethodCall = { fg = S.method_call }, -- call site (plain)
  Constructor = { fg = S.constructor },
  Macro = { fg = S.macro, bold = true },
  Attribute = { fg = S.attribute }, -- decorators / annotations

  -- ── Types ─────────────────────────────────────────────────────────────────
  Type = { fg = S.type_name }, -- type in usage
  TypeBuiltin = { fg = S.type_builtin }, -- int, bool, str…
  TypeDefinition = { fg = S.type_def }, -- the alias name: typedef X ← X
  Structure = { fg = S.struct_name }, -- struct name at definition
  Class = { fg = S.class_name }, -- class name
  Interface = { fg = S.interface_name }, -- interface/trait name
  Enum = { fg = S.enum_name, bold = true }, -- enum name
  TypeParameter = { fg = S.type_name, italic = true }, -- <T>, 'a lifetimes

  -- ── Keywords ──────────────────────────────────────────────────────────────
  Keyword = { fg = S.keyword },
  KeywordConditional = { fg = S.kw_conditional },
  KeywordRepeat = { fg = S.kw_repeat },
  KeywordReturn = { fg = S.kw_return },
  KeywordFunction = { fg = S.kw_function }, -- fn/def/func keyword
  KeywordType = { fg = S.kw_type }, -- struct/class/enum keyword
  KeywordModifier = { fg = S.kw_modifier }, -- const/static/pub/mut
  KeywordOperator = { fg = S.kw_operator, bold = true },
  KeywordException = { fg = S.kw_exception },
  KeywordImport = { fg = S.kw_import },
  KeywordCoroutine = { fg = S.kw_coroutine },
  KeywordDebug = { fg = S.kw_debug, bold = true },

  -- ── Preprocessor ──────────────────────────────────────────────────────────
  PreProc = { fg = S.preproc },
  PreProcDefine = { fg = S.preproc_define },
  Include = { fg = S.kw_import }, -- #include / import
  Define = { fg = S.preproc_define },

  -- ── Operators / punctuation ───────────────────────────────────────────────
  Operator = { fg = S.operator },
  Delimiter = { fg = S.delimiter },
  PunctuationBracket = { fg = S.bracket },
  PunctuationDelimiter = { fg = S.delimiter },
  PunctuationSpecial = { fg = S.punct_special },

  -- ── Tags (HTML/XML/JSX) ───────────────────────────────────────────────────
  Tag = { fg = S.tag_name, bold = true },
  TagBuiltin = { fg = S.tag_builtin },
  TagAttribute = { fg = S.tag_attr },
  TagDelimiter = { fg = S.tag_delim },

  -- ── LSP modifier overlays ─────────────────────────────────────────────────
  -- These are applied ON TOP of base type/variable colors by LSP.
  -- We express them as standalone Syn groups so they can be linked cleanly.
  ModReadonly = { fg = S.variable_const }, -- any readonly symbol → yellow
  ModDeprecated = { strikethrough = true }, -- crossed out
  ModAbstract = { italic = true }, -- abstract / virtual
  ModAsync = { italic = true }, -- async functions
  ModStatic = { italic = true }, -- static members
  ModDefaultLib = { italic = true }, -- stdlib symbols

  -- ── Diagnostics (syntax-side) ─────────────────────────────────────────────
  Error = { fg = S.error },
  Warning = { fg = S.warning },
  Info = { fg = S.info },
  Ok = { fg = S.ok },

  -- ── Diff (syntax-side) ────────────────────────────────────────────────────
  DiffAdd = { bg = U.diff_add },
  DiffDelete = { fg = U.vcs_removed, bg = U.diff_delete },
  DiffChange = { bg = U.diff_change },
  DiffText = { bg = U.diff_text },
}

-- ----------------------------------------------------------------------------
-- Editor UI Groups
-- ----------------------------------------------------------------------------
local Editor = {
  Normal = { fg = U.fg, bg = U.bg },
  NormalNC = config.dimInactive and { fg = U.fg_dim, bg = U.bg_dim } or { link = "Normal" },

  -- Unified float surface
  NormalFloat = { fg = P.white_warm, bg = U.float_bg },
  FloatBorder = { fg = U.float_border, bg = P.black0 },
  FloatTitle = { fg = U.fg_special, bg = U.float_bg, bold = true },
  FloatFooter = { fg = U.fg_nontext, bg = P.black0 },

  -- Cursor
  Cursor = { fg = U.bg, bg = P.teal },
  lCursor = { link = "Cursor" },
  CursorIM = { link = "Cursor" },
  TermCursor = { fg = U.bg, bg = P.red },

  -- Lines
  CursorLine = { bg = P.black5 },
  CursorColumn = { link = "CursorLine" },
  CursorLineNr = { fg = P.blue, bg = U.bg_gutter, bold = true },
  CursorLineFold = { fg = P.blue, bg = U.bg_gutter, bold = true },
  LineNr = { fg = U.fg_nontext, bg = U.bg_gutter },
  ColorColumn = { bg = P.black4 },

  -- Visual / search
  Visual = { bg = U.bg_visual },
  VisualNOS = { link = "Visual" },
  Search = { fg = U.fg, bg = U.bg_search },
  CurSearch = { fg = U.fg, bg = U.bg_search, bold = true },
  IncSearch = { fg = U.fg_reverse, bg = S.warning },
  Substitute = { fg = U.fg, bg = U.vcs_removed },

  -- Popup menu
  Pmenu = { fg = U.pmenu_fg, bg = U.pmenu_bg },
  PmenuSel = { fg = U.pmenu_fg_sel, bg = U.pmenu_bg_sel },
  PmenuSbar = { bg = U.pmenu_bg_sbar },
  PmenuThumb = { bg = U.pmenu_bg_thumb },

  -- Status / tabs / splits
  StatusLine = { fg = U.fg_dim, bg = P.black0 },
  StatusLineNC = { fg = U.fg_nontext, bg = P.black0 },
  TabLine = { fg = U.fg_special, bg = P.black0 },
  TabLineFill = { bg = U.bg },
  TabLineSel = { fg = U.fg_dim, bg = P.black4 },
  WinSeparator = { fg = P.black5, bg = config.dimInactive and U.bg_dim or "NONE" },
  VertSplit = { link = "WinSeparator" },
  Winbar = { fg = U.fg_dim, bg = "NONE" },
  WinbarNC = { fg = U.fg_dim, bg = config.dimInactive and U.bg_dim or "NONE" },

  -- Gutter / folds
  SignColumn = { fg = U.fg_special, bg = U.bg_gutter },
  FoldColumn = { fg = U.fg_nontext, bg = U.bg_gutter },
  Folded = { fg = P.gray, bg = P.black4 },

  -- Non-code
  NonText = { fg = U.fg_nontext },
  Whitespace = { fg = U.whitespace },
  EndOfBuffer = { fg = U.bg },
  SpecialKey = { fg = U.fg_special },
  Conceal = { fg = U.fg_special, bold = true },

  -- Misc
  Directory = { fg = S.func_builtin },
  Title = { fg = S.func_def, bold = true },
  MatchParen = { fg = S.warning, bold = true },
  QuickFixLine = { bg = P.black4 },
  WildMenu = { link = "Pmenu" },

  -- Messages
  ErrorMsg = { fg = S.error },
  WarningMsg = { fg = S.warning },
  ModeMsg = { fg = S.warning, bold = true },
  MoreMsg = { fg = S.info },
  Question = { link = "MoreMsg" },
  MsgArea = { fg = U.fg_dim },
  MsgSeparator = { bg = P.black0 },

  -- Spelling
  SpellBad = { undercurl = config.undercurl, sp = S.error },
  SpellCap = { undercurl = config.undercurl, sp = S.warning },
  SpellLocal = { undercurl = config.undercurl, sp = S.warning },
  SpellRare = { undercurl = config.undercurl, sp = S.warning },

  -- Diff
  DiffAdd = { link = "SynDiffAdd" },
  DiffChange = { link = "SynDiffChange" },
  DiffDelete = { link = "SynDiffDelete" },
  DiffText = { link = "SynDiffText" },

  -- VCS annotations (text fg, not bg)
  diffAdded = { fg = U.vcs_added },
  diffRemoved = { fg = U.vcs_removed },
  diffDeleted = { fg = U.vcs_removed },
  diffChanged = { fg = U.vcs_changed },
  diffOldFile = { fg = U.vcs_removed },
  diffNewFile = { fg = U.vcs_added },

  -- Diagnostics
  DiagnosticError = { fg = S.error },
  DiagnosticWarn = { fg = S.warning },
  DiagnosticInfo = { fg = S.info },
  DiagnosticHint = { fg = S.hint },
  DiagnosticOk = { fg = S.ok },

  DiagnosticSignError = { fg = S.error, bg = U.bg_gutter },
  DiagnosticSignWarn = { fg = S.warning, bg = U.bg_gutter },
  DiagnosticSignInfo = { fg = S.info, bg = U.bg_gutter },
  DiagnosticSignHint = { fg = S.hint, bg = U.bg_gutter },

  DiagnosticVirtualTextError = { link = "DiagnosticError" },
  DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },
  DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
  DiagnosticVirtualTextHint = { link = "DiagnosticHint" },

  DiagnosticUnderlineError = { undercurl = config.undercurl, sp = S.error },
  DiagnosticUnderlineWarn = { undercurl = config.undercurl, sp = S.warning },
  DiagnosticUnderlineInfo = { undercurl = config.undercurl, sp = S.info },
  DiagnosticUnderlineHint = { undercurl = config.undercurl, sp = S.hint },

  -- LSP
  LspReferenceText = { bg = U.diff_text },
  LspReferenceRead = { link = "LspReferenceText" },
  LspReferenceWrite = { bg = U.diff_text, underline = true },
  LspSignatureActiveParameter = { fg = S.warning },
  LspCodeLens = { link = "SynComment" },
  LspInlayHint = { link = "SynCommentDocumentation" },

  -- Debug
  debugPC = { bg = U.diff_delete },
  debugBreakpoint = { fg = S.info, bg = U.bg_gutter },
}

-- ----------------------------------------------------------------------------
-- Vim Syntax Fallback  (classic :hi groups → link to Syn*)
-- ----------------------------------------------------------------------------
local VimSyntax = {
  -- Literals
  Comment = { link = "SynComment" },
  Constant = { link = "SynConstant" },
  String = { link = "SynString" },
  Character = { link = "SynCharacter" },
  Number = { link = "SynNumber" },
  Boolean = { link = "SynBoolean" },
  Float = { link = "SynFloat" },

  -- Identifiers
  Identifier = { link = "SynVariable" },
  Function = { link = "SynFunction" },

  -- Statements
  Statement = { link = "SynKeyword" },
  Conditional = { link = "SynKeywordConditional" },
  Repeat = { link = "SynKeywordRepeat" },
  Label = { link = "SynLabel" },
  Operator = { link = "SynOperator" },
  Keyword = { link = "SynKeyword" },
  Exception = { link = "SynKeywordException" },

  -- Preprocessor
  PreProc = { link = "SynPreProc" },
  Include = { link = "SynInclude" },
  Define = { link = "SynDefine" },
  Macro = { link = "SynMacro" },
  PreCondit = { link = "SynPreProc" },

  -- Types
  Type = { link = "SynType" },
  StorageClass = { link = "SynKeywordModifier" },
  Structure = { link = "SynStructure" },
  Typedef = { link = "SynTypeDefinition" },

  -- Special
  Special = { link = "SynStringSpecial" },
  SpecialChar = { link = "SynStringEscape" },
  Tag = { link = "SynTag" },
  Delimiter = { link = "SynDelimiter" },
  SpecialComment = { link = "SynCommentDocumentation" },

  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },
  Ignore = { link = "NonText" },
  Error = { link = "SynError" },
  Todo = { link = "SynCommentTodo" },

  qfLineNr = { link = "LineNr" },
  qfFileName = { link = "Directory" },

  markdownCode = { link = "SynString" },
  markdownCodeBlock = { link = "SynString" },
  markdownEscape = { fg = "NONE" },
}

-- ----------------------------------------------------------------------------
-- Treesitter  (every capture from the spec, linked to Syn*)
-- ----------------------------------------------------------------------------
local Treesitter = {
  -- ── Comments ────────────────────────────────────────────────────────────
  ["@comment"] = { link = "SynComment" },
  ["@comment.documentation"] = { link = "SynCommentDocumentation" },
  ["@comment.todo"] = { link = "SynCommentTodo" },
  ["@comment.note"] = { link = "SynCommentNote" },
  ["@comment.warning"] = { link = "SynCommentWarning" },
  ["@comment.error"] = { link = "SynCommentError" },

  -- ── Strings ─────────────────────────────────────────────────────────────
  ["@string"] = { link = "SynString" },
  ["@string.documentation"] = { link = "SynCommentDocumentation" }, -- Python docstrings
  ["@string.regexp"] = { link = "SynStringRegex" },
  ["@string.escape"] = { link = "SynStringEscape" },
  ["@string.special"] = { link = "SynStringSpecial" },
  ["@string.special.symbol"] = { link = "SynStringSpecial" },
  ["@string.special.path"] = { link = "SynStringPath" },
  ["@string.special.url"] = { link = "SynStringUrl" },

  -- ── Characters ──────────────────────────────────────────────────────────
  ["@character"] = { link = "SynCharacter" },
  ["@character.special"] = { link = "SynStringEscape" },

  -- ── Literals ────────────────────────────────────────────────────────────
  ["@boolean"] = { link = "SynBoolean" },
  ["@number"] = { link = "SynNumber" },
  ["@number.float"] = { link = "SynFloat" },

  -- ── Constants ───────────────────────────────────────────────────────────
  -- All constant → yellow (same as readonly vars — "won't change")
  ["@constant"] = { link = "SynConstant" },
  ["@constant.builtin"] = { link = "SynNil" }, -- nil/true/false builtins
  ["@constant.macro"] = { link = "SynMacro" }, -- #define'd constants

  -- ── Variables — the mutable/const split lives here ──────────────────────
  -- Plain vars: white.  LSP readonly modifier will shift them to yellow.
  ["@variable"] = { link = "SynVariable" },
  ["@variable.builtin"] = { link = "SynVariableBuiltin" },
  ["@variable.parameter"] = { link = "SynParameter" },
  ["@variable.parameter.builtin"] = { link = "SynVariableBuiltin" }, -- _, it
  ["@variable.member"] = { link = "SynField" }, -- mutable member

  -- ── Modules / namespaces / labels ────────────────────────────────────────
  ["@module"] = { link = "SynNamespace" },
  ["@module.builtin"] = { link = "SynVariableBuiltin" },
  ["@label"] = { link = "SynLabel" },

  -- ── Functions — definition vs call ──────────────────────────────────────
  ["@function"] = { link = "SynFunction" }, -- definition
  ["@function.builtin"] = { link = "SynFunctionBuiltin" },
  ["@function.call"] = { link = "SynFunctionCall" }, -- call site
  ["@function.macro"] = { link = "SynMacro" },
  ["@function.method"] = { link = "SynMethod" }, -- definition
  ["@function.method.call"] = { link = "SynMethodCall" }, -- call site
  ["@constructor"] = { link = "SynConstructor" },

  -- ── Types ───────────────────────────────────────────────────────────────
  ["@type"] = { link = "SynType" },
  ["@type.builtin"] = { link = "SynTypeBuiltin" },
  ["@type.definition"] = { link = "SynTypeDefinition" },

  -- ── Attributes / properties ─────────────────────────────────────────────
  ["@attribute"] = { link = "SynAttribute" },
  ["@attribute.builtin"] = { link = "SynAttribute" },
  ["@property"] = { link = "SynProperty" }, -- key/value key

  -- ── Operators ───────────────────────────────────────────────────────────
  ["@operator"] = { link = "SynOperator" },

  -- ── Keywords ────────────────────────────────────────────────────────────
  ["@keyword"] = { link = "SynKeyword" },
  ["@keyword.coroutine"] = { link = "SynKeywordCoroutine" },
  ["@keyword.function"] = { link = "SynKeywordFunction" },
  ["@keyword.operator"] = { link = "SynKeywordOperator" },
  ["@keyword.import"] = { link = "SynKeywordImport" },
  ["@keyword.type"] = { link = "SynKeywordType" },
  ["@keyword.modifier"] = { link = "SynKeywordModifier" },
  ["@keyword.repeat"] = { link = "SynKeywordRepeat" },
  ["@keyword.return"] = { link = "SynKeywordReturn" },
  ["@keyword.debug"] = { link = "SynKeywordDebug" },
  ["@keyword.exception"] = { link = "SynKeywordException" },
  ["@keyword.conditional"] = { link = "SynKeywordConditional" },
  ["@keyword.conditional.ternary"] = { link = "SynKeywordConditional" },
  ["@keyword.directive"] = { link = "SynPreProc" },
  ["@keyword.directive.define"] = { link = "SynPreProcDefine" },

  -- ── Punctuation ─────────────────────────────────────────────────────────
  ["@punctuation.delimiter"] = { link = "SynPunctuationDelimiter" },
  ["@punctuation.bracket"] = { link = "SynPunctuationBracket" },
  ["@punctuation.special"] = { link = "SynPunctuationSpecial" },

  -- ── Tags ────────────────────────────────────────────────────────────────
  ["@tag"] = { link = "SynTag" },
  ["@tag.builtin"] = { link = "SynTagBuiltin" },
  ["@tag.attribute"] = { link = "SynTagAttribute" },
  ["@tag.delimiter"] = { link = "SynTagDelimiter" },

  -- ── Diffs ───────────────────────────────────────────────────────────────
  ["@diff.plus"] = { fg = U.vcs_added },
  ["@diff.minus"] = { fg = U.vcs_removed },
  ["@diff.delta"] = { fg = U.vcs_changed },

  -- ── Markup (markdown / rst / org / latex) ───────────────────────────────
  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },

  ["@markup.heading"] = { fg = S.func_def, bold = true },
  ["@markup.heading.1"] = { fg = P.red, bold = true },
  ["@markup.heading.2"] = { fg = S.kw_conditional, bold = true },
  ["@markup.heading.3"] = { fg = S.keyword, bold = true },
  ["@markup.heading.4"] = { fg = S.string, bold = true },
  ["@markup.heading.5"] = { fg = S.type_name, bold = true },
  ["@markup.heading.6"] = { fg = P.gray, bold = true },

  ["@markup.quote"] = { link = "SynComment" },
  ["@markup.math"] = { fg = P.teal },

  ["@markup.link"] = { fg = S.builtin_var, underline = true },
  ["@markup.link.label"] = { link = "SynStringSpecial" },
  ["@markup.link.url"] = { link = "SynStringUrl" },

  ["@markup.raw"] = { link = "SynString" },
  ["@markup.raw.block"] = { link = "SynString" },

  ["@markup.list"] = { link = "SynPunctuationSpecial" },
  ["@markup.list.checked"] = { fg = S.ok, bold = true },
  ["@markup.list.unchecked"] = { fg = U.fg_special },
}

-- ----------------------------------------------------------------------------
-- LSP Semantic Tokens
--
-- Philosophy for modifiers:
--   @lsp.type.*      → base color (same as TS groups above)
--   @lsp.mod.readonly / @lsp.mod.modification → shift color to yellow/white
--   @lsp.mod.deprecated  → strikethrough
--   @lsp.mod.abstract    → italic
--   @lsp.mod.async       → italic
--   @lsp.mod.static      → italic
--   @lsp.mod.defaultLibrary → italic (stdlib tint)
--
-- typemod = type + modifier combined, for precision overrides.
-- ----------------------------------------------------------------------------
local LspSemantic = {
  -- ── Base types ─────────────────────────────────────────────────────────
  ["@lsp.type.class"] = { link = "SynClass" },
  ["@lsp.type.struct"] = { link = "SynStructure" },
  ["@lsp.type.interface"] = { link = "SynInterface" },
  ["@lsp.type.enum"] = { link = "SynEnum" },
  ["@lsp.type.enumMember"] = { link = "SynEnumMember" },
  ["@lsp.type.type"] = { link = "SynType" },
  ["@lsp.type.typeParameter"] = { link = "SynTypeParameter" },
  ["@lsp.type.function"] = { link = "SynFunction" },
  ["@lsp.type.method"] = { link = "SynMethod" },
  ["@lsp.type.macro"] = { link = "SynMacro" },
  ["@lsp.type.decorator"] = { link = "SynAttribute" },
  ["@lsp.type.event"] = { fg = P.teal }, -- event properties
  ["@lsp.type.namespace"] = { link = "SynNamespace" },
  ["@lsp.type.variable"] = { link = "SynVariable" }, -- mutable by default
  ["@lsp.type.parameter"] = { link = "SynParameter" },
  ["@lsp.type.property"] = { link = "SynProperty" },
  ["@lsp.type.modifier"] = { link = "SynKeywordModifier" },
  ["@lsp.type.keyword"] = { link = "SynKeyword" },
  ["@lsp.type.comment"] = { link = "SynComment" },
  ["@lsp.type.string"] = { link = "SynString" },
  ["@lsp.type.number"] = { link = "SynNumber" },
  ["@lsp.type.regexp"] = { link = "SynStringRegex" },
  ["@lsp.type.operator"] = { link = "SynOperator" },

  -- ── Modifiers — the const/mutable split ────────────────────────────────
  --
  -- readonly: shift to yellow (same as const_val, number, enum_member)
  -- This is the primary way const fields/vars/params get distinguished.
  ["@lsp.mod.readonly"] = { fg = S.variable_const }, -- → yellow
  -- modification: a write to a variable — keep white, no special color needed
  -- (neovim uses this for write refs in LspReference; handled via LspReferenceWrite)

  -- deprecated: visible strikethrough so you notice immediately
  ["@lsp.mod.deprecated"] = { strikethrough = true },

  -- abstract / virtual: italic to indicate "not concrete here"
  ["@lsp.mod.abstract"] = { italic = true },

  -- async: italic — signals "this suspends"
  ["@lsp.mod.async"] = { italic = true },

  -- static: italic — signals "belongs to type, not instance"
  ["@lsp.mod.static"] = { italic = true },

  -- defaultLibrary / stdlib: italic tint so you know it's not your code
  ["@lsp.mod.defaultLibrary"] = { italic = true },

  -- documentation: treat like doc comment
  ["@lsp.mod.documentation"] = { link = "SynCommentDocumentation" },

  -- declaration / definition: DO NOT set a standalone highlight here.
  -- A flat { bold=true } overrides the base type color at prio 126 and
  -- destroys the const/mutable split for any symbol that is also a declaration.
  -- Bold is expressed only in the explicit typemod combinations below.
  -- ["@lsp.mod.declaration"] = intentionally omitted
  -- ["@lsp.mod.definition"]  = intentionally omitted

  -- ── typemod combinations — precision const/mutable overrides ────────────
  -- Priority 127. Language-suffixed (.cpp) versions are what clangd emits;
  -- unsuffixed versions are the fallback for rust-analyzer, pylsp, etc.

  -- readonly variables → yellow
  ["@lsp.typemod.variable.readonly"] = { link = "SynVariableConst" },
  ["@lsp.typemod.variable.static"] = { link = "SynVariable", italic = true },

  -- ── Parameters: full declaration × readonly matrix ───────────────────────
  -- Non-const parameter at any site → white+italic
  ["@lsp.typemod.parameter.declaration"] = { link = "SynParameter" },
  ["@lsp.typemod.parameter.definition"] = { link = "SynParameter" },
  ["@lsp.typemod.parameter.declaration.cpp"] = { link = "SynParameter" },
  ["@lsp.typemod.parameter.definition.cpp"] = { link = "SynParameter" },
  -- Const parameter at use site → yellow+italic
  ["@lsp.typemod.parameter.readonly"] = { link = "SynParameterConst" },
  ["@lsp.typemod.parameter.readonly.cpp"] = { link = "SynParameterConst" },
  -- Const parameter at declaration/definition site → yellow+italic
  -- These beat the declaration entries above because they have more modifiers.
  ["@lsp.typemod.parameter.readonly.declaration"] = { link = "SynParameterConst" },
  ["@lsp.typemod.parameter.readonly.definition"] = { link = "SynParameterConst" },
  ["@lsp.typemod.parameter.readonly.declaration.cpp"] = { link = "SynParameterConst" },
  ["@lsp.typemod.parameter.readonly.definition.cpp"] = { link = "SynParameterConst" },

  -- readonly / const fields and properties → yellow
  ["@lsp.typemod.property.readonly"] = { link = "SynPropertyConst" },
  ["@lsp.typemod.property.readonly.cpp"] = { link = "SynPropertyConst" },
  ["@lsp.typemod.property.static"] = { link = "SynProperty", italic = true },

  -- enum members are always const — already yellow, keep bold too
  ["@lsp.typemod.enumMember.readonly"] = { link = "SynEnumMember" },

  -- stdlib functions → builtin style
  ["@lsp.typemod.function.defaultLibrary"] = { link = "SynFunctionBuiltin" },
  ["@lsp.typemod.method.defaultLibrary"] = { link = "SynFunctionBuiltin" },

  -- stdlib types → builtin type style
  ["@lsp.typemod.type.defaultLibrary"] = { link = "SynTypeBuiltin" },
  ["@lsp.typemod.class.defaultLibrary"] = { link = "SynTypeBuiltin" },

  -- abstract classes / methods → italic
  ["@lsp.typemod.class.abstract"] = { fg = S.class_name, italic = true },
  ["@lsp.typemod.method.abstract"] = { fg = S.method_def, italic = true },

  -- async functions → italic
  ["@lsp.typemod.function.async"] = { fg = S.func_def, italic = true },
  ["@lsp.typemod.method.async"] = { fg = S.method_def, italic = true },

  -- static methods → italic
  ["@lsp.typemod.method.static"] = { fg = S.method_def, italic = true },
  ["@lsp.typemod.function.static"] = { fg = S.func_def, italic = true },

  -- deprecated anything → strikethrough
  ["@lsp.typemod.variable.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.function.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.method.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.type.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.class.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.property.deprecated"] = { strikethrough = true },

  -- declaration/definition sites get bold (you're naming something)
  ["@lsp.typemod.function.declaration"] = { fg = S.func_def, bold = true },
  ["@lsp.typemod.method.declaration"] = { fg = S.method_def, bold = true },
  ["@lsp.typemod.class.declaration"] = { fg = S.class_name, bold = true },

  -- inlay hints
  LspInlayHint = { link = "SynCommentDocumentation" },
}

-- ----------------------------------------------------------------------------
-- Plugin Groups
-- ----------------------------------------------------------------------------
local Plugins = {
  -- Gitsigns
  GitSignsAdd = { fg = U.vcs_added, bg = U.bg_gutter },
  GitSignsChange = { fg = U.vcs_changed, bg = U.bg_gutter },
  GitSignsDelete = { fg = U.vcs_removed, bg = U.bg_gutter },

  -- Treesitter context
  TreesitterContext = { link = "Folded" },
  TreesitterContextLineNumber = { fg = U.fg_special, bg = U.bg_gutter },

  -- Telescope
  TelescopeNormal = { link = "NormalFloat" },
  TelescopeBorder = { link = "FloatBorder" },
  TelescopeTitle = { fg = S.func_def, bg = U.float_bg, bold = true },
  TelescopeSelection = { link = "CursorLine" },
  TelescopeSelectionCaret = { link = "CursorLineNr" },
  TelescopeResultsClass = { link = "SynStructure" },
  TelescopeResultsStruct = { link = "SynStructure" },
  TelescopeResultsField = { link = "SynField" },
  TelescopeResultsMethod = { link = "SynMethod" },
  TelescopeResultsVariable = { link = "SynVariable" },

  -- nvim-cmp / Blink
  CmpDocumentation = { link = "NormalFloat" },
  CmpDocumentationBorder = { link = "FloatBorder" },
  CmpCompletion = { link = "Pmenu" },
  CmpCompletionSel = { fg = "NONE", bg = U.pmenu_bg_sel },
  CmpCompletionBorder = { link = "FloatBorder" },
  CmpCompletionThumb = { link = "PmenuThumb" },
  CmpCompletionSbar = { link = "PmenuSbar" },
  CmpItemAbbr = { fg = U.pmenu_fg },
  CmpItemAbbrDeprecated = { fg = S.comment_doc, strikethrough = true },
  CmpItemAbbrMatch = { fg = S.func_builtin },
  CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
  CmpItemKindDefault = { link = "SynAttribute" },
  CmpItemMenu = { fg = S.comment_doc },
  CmpItemKindVariable = { fg = U.fg_dim },
  CmpItemKindFunction = { link = "SynFunction" },
  CmpItemKindMethod = { link = "SynMethod" },
  CmpItemKindConstructor = { link = "SynConstructor" },
  CmpItemKindClass = { link = "SynClass" },
  CmpItemKindInterface = { link = "SynInterface" },
  CmpItemKindStruct = { link = "SynStructure" },
  CmpItemKindEnum = { link = "SynEnum" },
  CmpItemKindEnumMember = { link = "SynEnumMember" },
  CmpItemKindConstant = { link = "SynConstant" },
  CmpItemKindProperty = { link = "SynProperty" },
  CmpItemKindField = { link = "SynField" },
  CmpItemKindKeyword = { link = "SynKeyword" },
  CmpItemKindString = { link = "SynString" },
  CmpItemKindNumber = { link = "SynNumber" },
  CmpItemKindOperator = { link = "SynOperator" },
  CmpItemKindModule = { link = "SynNamespace" },
  CmpItemKindFile = { link = "Directory" },
  CmpItemKindFolder = { link = "Directory" },
  CmpItemKindSnippet = { fg = S.comment },
  CmpItemKindCopilot = { link = "SynString" },
  CmpItemKindTypeParameter = { link = "SynTypeParameter" },
  CmpItemKindReference = { link = "SynType" },
  CmpItemKindValue = { link = "SynConstant" },
  CmpItemKindEvent = { fg = P.teal },
  CmpItemKindText = { fg = U.pmenu_fg },

  BlinkCmpItemIdx = { link = "SynComment" },
  BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
  BlinkCmpMenuBorder = { link = "FloatBorder" },
  BlinkCmpDocBorder = { link = "FloatBorder" },

  -- IndentBlankline
  IblIndent = { fg = U.whitespace },
  IblWhitespace = { fg = U.whitespace },
  IblScope = { fg = U.fg_special },

  -- Illuminate
  IlluminatedWordText = { bg = P.black5 },
  IlluminatedWordRead = { link = "IlluminatedWordText" },
  IlluminatedWordWrite = { link = "IlluminatedWordText" },

  -- Incline
  InclineNormal = { fg = S.const_val },
  InclineNormalNC = { fg = U.fg_special },

  -- DAP UI
  DapUIFloatBorder = { link = "FloatBorder" },
  DapUIScope = { link = "SynType" },
  DapUIType = { link = "SynType" },
  DapUIModifiedValue = { fg = S.func_def, bold = true },
  DapUIDecoration = { fg = U.float_border },
  DapUIThread = { link = "SynNamespace" },
  DapUIStoppedThread = { fg = S.func_def },
  DapUISource = { link = "SynNamespace" },
  DapUILineNumber = { fg = S.func_def },
  DapUIWatchesEmpty = { fg = S.error },
  DapUIWatchesValue = { link = "SynVariable" },
  DapUIWatchesError = { fg = S.error },
  DapUIBreakpointsPath = { link = "Directory" },
  DapUIBreakpointsInfo = { fg = S.info },
  DapUIBreakpointsCurrentLine = { fg = S.func_def, bold = true },
  DapUIBreakpointsDisabledLine = { link = "SynComment" },
  DapUIStepOver = { fg = S.func_def },
  DapUIStepInto = { fg = S.func_def },
  DapUIStepBack = { fg = S.func_def },
  DapUIStepOut = { fg = S.func_def },
  DapUIStop = { fg = S.error },
  DapUIPlayPause = { fg = S.ok },
  DapUIRestart = { fg = S.ok },
  DapUIUnavailable = { link = "SynComment" },

  -- UFO (folding)
  UfoFoldedFg = { fg = U.fg_special },
  UfoFoldedBg = { bg = P.black4 },
  UfoPreviewSbar = { link = "PmenuSbar" },
  UfoPreviewThumb = { link = "PmenuThumb" },
  UfoPreviewWinBar = { link = "UfoFoldedBg" },
  UfoPreviewCursorLine = { link = "Visual" },
  UfoFoldedEllipsis = { link = "SynComment" },
  UfoCursorFoldedLine = { link = "CursorLine" },

  -- Floaterm
  FloatermBorder = { link = "FloatBorder" },

  -- Lazy
  LazyProgressTodo = { fg = U.nontext },

  -- Health
  healthError = { fg = S.error },
  healthSuccess = { fg = S.ok },
  healthWarning = { fg = S.warning },
}

-- ----------------------------------------------------------------------------
-- Language-specific
-- ----------------------------------------------------------------------------
local Lang = {
  -- C / C++
  cStorageClass = { fg = S.kw_modifier, italic = true }, -- static/const/volatile
  cppSTLnamespace = { link = "SynNamespace" },
  cppSTLfunction = { link = "SynFunctionBuiltin" },
  cppSTLtype = { link = "SynTypeBuiltin" },
  cppAccess = { link = "SynKeyword" }, -- public/private/protected
  cppStatement = { link = "SynKeyword" },
  cppModifier = { link = "SynKeywordModifier" }, -- const/volatile

  -- Rust (handled well by LSP, but TS fallback)
  rustKeyword = { link = "SynKeyword" },
  rustModifier = { link = "SynKeywordModifier" }, -- mut, pub

  -- Lua
  luaLocal = { link = "SynKeywordModifier" },
}

-- ----------------------------------------------------------------------------
-- Apply  (Syn* registered first so all links resolve)
-- ----------------------------------------------------------------------------
local function set_hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function merge_overrides(bucket, tbl)
  for g, v in pairs((config.overrides or {})[bucket] or {}) do
    tbl[g] = vim.tbl_extend("force", tbl[g] or {}, v)
  end
end

merge_overrides("syn", Syn)
merge_overrides("editor", Editor)
merge_overrides("vim", VimSyntax)
merge_overrides("ts", Treesitter)
merge_overrides("lsp", LspSemantic)
merge_overrides("plugins", Plugins)
merge_overrides("lang", Lang)

for name, opts in pairs(Syn) do
  set_hl("Syn" .. name, opts)
end
for g, opts in pairs(Editor) do
  set_hl(g, opts)
end
for g, opts in pairs(VimSyntax) do
  set_hl(g, opts)
end
for g, opts in pairs(Treesitter) do
  set_hl(g, opts)
end
for g, opts in pairs(LspSemantic) do
  set_hl(g, opts)
end
for g, opts in pairs(Plugins) do
  set_hl(g, opts)
end
for g, opts in pairs(Lang) do
  set_hl(g, opts)
end

-- ----------------------------------------------------------------------------
-- Terminal colors
-- ----------------------------------------------------------------------------
vim.g.terminal_color_0 = P.black0 -- black
vim.g.terminal_color_1 = P.red -- red
vim.g.terminal_color_2 = P.green2 -- green
vim.g.terminal_color_3 = P.yellow -- yellow
vim.g.terminal_color_4 = P.blue -- blue
vim.g.terminal_color_5 = P.violet -- magenta
vim.g.terminal_color_6 = P.aqua -- cyan
vim.g.terminal_color_7 = P.white_dim -- white
vim.g.terminal_color_8 = P.gray -- bright black
vim.g.terminal_color_9 = P.wave_red -- bright red
vim.g.terminal_color_10 = P.green -- bright green
vim.g.terminal_color_11 = P.carp_yellow -- bright yellow
vim.g.terminal_color_12 = P.blue -- bright blue
vim.g.terminal_color_13 = P.violet1 -- bright magenta
vim.g.terminal_color_14 = P.wave_aqua2 -- bright cyan
vim.g.terminal_color_15 = P.white -- bright white
vim.g.terminal_color_background = P.black3
vim.g.terminal_color_foreground = P.white

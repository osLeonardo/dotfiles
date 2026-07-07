-- Atom colorscheme for Neovim
-- Ported from the "Atom" iTerm2-Color-Schemes palette
-- https://github.com/mbadolato/iTerm2-Color-Schemes

local M = {}

local colors = {
  bg = "#222222",
  bg_alt = "#2a2a2a", -- slightly lighter, for panels/statusline
  bg_visual = "#383838",
  fg = "#C5C8C6",
  fg_dim = "#8a8d90",
  cursor = "#C5C8C6",
  cursor_fg = "#161719",
  selection = "#4a4a4a",
  black = "#000000",
  pink = "#FD5FF1",
  green = "#87C38A",
  green_br = "#94FA36",
  tan = "#FFD7B1",
  yellow = "#F5FFA8",
  blue = "#85BEFD",
  blue_br = "#96CBFE",
  purple = "#B9B6FC",
  white = "#E0E0E0",
  red = "#FF5F5F", -- Atom's ANSI set has no distinct red; added for diagnostics
}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.termguicolors = true
  vim.g.colors_name = "atom"

  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- Editor UI
  hl("Normal", { fg = colors.fg, bg = colors.bg })
  hl("NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
  hl("FloatBorder", { fg = colors.purple, bg = colors.bg_alt })
  hl("Cursor", { fg = colors.cursor_fg, bg = colors.cursor })
  hl("CursorLine", { bg = colors.bg_alt })
  hl("CursorLineNr", { fg = colors.pink, bold = true })
  hl("LineNr", { fg = colors.fg_dim })
  hl("SignColumn", { bg = colors.bg })
  hl("ColorColumn", { bg = colors.bg_alt })
  hl("Visual", { bg = colors.bg_visual })
  hl("VisualNOS", { bg = colors.bg_visual })
  hl("Search", { fg = colors.black, bg = colors.yellow })
  hl("IncSearch", { fg = colors.black, bg = colors.pink })
  hl("Pmenu", { fg = colors.fg, bg = colors.bg_alt })
  hl("PmenuSel", { fg = colors.black, bg = colors.blue })
  hl("PmenuSbar", { bg = colors.bg_alt })
  hl("PmenuThumb", { bg = colors.selection })
  hl("StatusLine", { fg = colors.fg, bg = colors.bg_alt })
  hl("StatusLineNC", { fg = colors.fg_dim, bg = colors.bg_alt })
  hl("WinSeparator", { fg = colors.selection, bg = colors.bg })
  hl("VertSplit", { fg = colors.selection, bg = colors.bg })
  hl("TabLine", { fg = colors.fg_dim, bg = colors.bg_alt })
  hl("TabLineSel", { fg = colors.fg, bg = colors.bg })
  hl("Directory", { fg = colors.blue })
  hl("Title", { fg = colors.pink, bold = true })
  hl("NonText", { fg = colors.selection })
  hl("Whitespace", { fg = colors.selection })
  hl("MatchParen", { fg = colors.tan, bold = true })

  -- Diagnostics
  hl("DiagnosticError", { fg = colors.red })
  hl("DiagnosticWarn", { fg = colors.pink })
  hl("DiagnosticInfo", { fg = colors.blue })
  hl("DiagnosticHint", { fg = colors.purple })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.pink })
  hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.blue })
  hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.purple })

  -- Diff / git
  hl("DiffAdd", { fg = colors.green, bg = colors.bg_alt })
  hl("DiffChange", { fg = colors.pink, bg = colors.bg_alt })
  hl("DiffDelete", { fg = colors.red, bg = colors.bg_alt })
  hl("DiffText", { fg = colors.blue, bg = colors.bg_alt })
  hl("GitSignsAdd", { fg = colors.green })
  hl("GitSignsChange", { fg = colors.pink })
  hl("GitSignsDelete", { fg = colors.red })

  -- Classic syntax groups
  hl("Comment", { fg = colors.fg_dim, italic = true })
  hl("Constant", { fg = colors.pink })
  hl("String", { fg = colors.green })
  hl("Character", { fg = colors.green })
  hl("Number", { fg = colors.pink })
  hl("Boolean", { fg = colors.pink })
  hl("Float", { fg = colors.pink })
  hl("Identifier", { fg = colors.white })
  hl("Function", { fg = colors.blue })
  hl("Statement", { fg = colors.tan })
  hl("Conditional", { fg = colors.tan })
  hl("Repeat", { fg = colors.tan })
  hl("Label", { fg = colors.tan })
  hl("Operator", { fg = colors.fg })
  hl("Keyword", { fg = colors.tan })
  hl("Exception", { fg = colors.tan })
  hl("PreProc", { fg = colors.purple })
  hl("Include", { fg = colors.purple })
  hl("Define", { fg = colors.purple })
  hl("Macro", { fg = colors.purple })
  hl("Type", { fg = colors.purple })
  hl("StorageClass", { fg = colors.purple })
  hl("Structure", { fg = colors.purple })
  hl("Typedef", { fg = colors.purple })
  hl("Special", { fg = colors.blue_br })
  hl("Underlined", { fg = colors.blue, underline = true })
  hl("Error", { fg = colors.red, bold = true })
  hl("Todo", { fg = colors.black, bg = colors.yellow, bold = true })

  -- Treesitter (what LazyVim actually relies on)
  hl("@variable", { fg = colors.white })
  hl("@variable.builtin", { fg = colors.pink, italic = true })
  hl("@variable.parameter", { fg = colors.white })
  hl("@variable.member", { fg = colors.white })
  hl("@constant", { fg = colors.pink })
  hl("@constant.builtin", { fg = colors.pink, italic = true })
  hl("@string", { fg = colors.green })
  hl("@string.escape", { fg = colors.blue_br })
  hl("@number", { fg = colors.pink })
  hl("@boolean", { fg = colors.pink })
  hl("@function", { fg = colors.blue })
  hl("@function.builtin", { fg = colors.blue_br })
  hl("@function.call", { fg = colors.blue })
  hl("@method", { fg = colors.blue })
  hl("@method.call", { fg = colors.blue })
  hl("@constructor", { fg = colors.purple })
  hl("@keyword", { fg = colors.tan })
  hl("@keyword.function", { fg = colors.tan })
  hl("@keyword.return", { fg = colors.tan })
  hl("@keyword.operator", { fg = colors.tan })
  hl("@conditional", { fg = colors.tan })
  hl("@repeat", { fg = colors.tan })
  hl("@type", { fg = colors.purple })
  hl("@type.builtin", { fg = colors.purple, italic = true })
  hl("@property", { fg = colors.white })
  hl("@field", { fg = colors.white })
  hl("@parameter", { fg = colors.white })
  hl("@comment", { fg = colors.fg_dim, italic = true })
  hl("@punctuation.bracket", { fg = colors.fg })
  hl("@punctuation.delimiter", { fg = colors.fg })
  hl("@tag", { fg = colors.tan })
  hl("@tag.attribute", { fg = colors.blue })
  hl("@tag.delimiter", { fg = colors.fg })

  -- LSP semantic tokens (Angular/TS/C# rely heavily on these)
  hl("@lsp.type.class", { fg = colors.purple })
  hl("@lsp.type.interface", { fg = colors.purple })
  hl("@lsp.type.enum", { fg = colors.purple })
  hl("@lsp.type.parameter", { fg = colors.white })
  hl("@lsp.type.property", { fg = colors.white })
  hl("@lsp.type.variable", { fg = colors.white })
  hl("@lsp.type.function", { fg = colors.blue })
  hl("@lsp.type.method", { fg = colors.blue })
  hl("@lsp.type.decorator", { fg = colors.blue_br })
  hl("@lsp.type.namespace", { fg = colors.purple })

  -- Telescope
  hl("TelescopeBorder", { fg = colors.selection })
  hl("TelescopeSelection", { bg = colors.bg_alt })
  hl("TelescopePromptBorder", { fg = colors.purple })
  hl("TelescopeMatching", { fg = colors.pink, bold = true })

  -- Bufferline / which-key / misc LazyVim UI
  hl("WhichKey", { fg = colors.tan })
  hl("WhichKeyGroup", { fg = colors.blue })
  hl("WhichKeyDesc", { fg = colors.fg })
  hl("NoiceCmdlinePopupBorder", { fg = colors.purple })
end

M.setup()

return M

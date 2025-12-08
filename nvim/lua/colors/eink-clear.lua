-- eink-clear: Minimal, almost monochrome with subtle blue accents
-- Optimized for 4096-color e-ink displays

vim.cmd("highlight clear")
vim.o.background = "light"
vim.g.colors_name = "eink-clear"

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Base colors
local bg = "#ffffff"
local fg = "#000000"
local gray1 = "#f0f0f0"
local gray2 = "#d0d0d0"
local gray3 = "#808080"
local accent = "#0055aa"

-- Editor
hi("Normal", { fg = fg, bg = bg })
hi("NormalFloat", { fg = fg, bg = bg })
hi("FloatBorder", { fg = gray3, bg = bg })
hi("Cursor", { fg = bg, bg = fg })
hi("CursorLine", { bg = gray1 })
hi("CursorLineNr", { fg = fg, bold = true })
hi("LineNr", { fg = gray3 })
hi("SignColumn", { bg = bg })
hi("VertSplit", { fg = gray2 })
hi("StatusLine", { fg = fg, bg = bg })
hi("StatusLineNC", { fg = gray3, bg = bg })
hi("Pmenu", { fg = fg, bg = bg })
hi("PmenuSel", { fg = bg, bg = fg })
hi("Visual", { bg = gray2 })
hi("Search", { fg = bg, bg = accent })
hi("IncSearch", { fg = bg, bg = fg })
hi("MatchParen", { fg = accent, bold = true, underline = true })

-- Syntax - minimal color
hi("Comment", { fg = gray3, italic = true })
hi("Constant", { fg = fg })
hi("String", { fg = "#006600" })
hi("Number", { fg = fg })
hi("Boolean", { fg = fg, bold = true })
hi("Identifier", { fg = fg })
hi("Function", { fg = fg, bold = true })
hi("Statement", { fg = fg, bold = true })
hi("Keyword", { fg = fg, bold = true })
hi("Operator", { fg = fg })
hi("PreProc", { fg = gray3 })
hi("Type", { fg = fg })
hi("Special", { fg = accent })
hi("Error", { fg = "#aa0000", bold = true })
hi("Todo", { fg = accent, bold = true })

-- Diff
hi("DiffAdd", { bg = "#e0ffe0" })
hi("DiffChange", { bg = "#ffffd0" })
hi("DiffDelete", { fg = "#aa0000", bg = "#ffe0e0" })
hi("DiffText", { bg = "#ffffaa", bold = true })

-- Markdown
hi("htmlH1", { fg = fg, bold = true })
hi("htmlH2", { fg = fg, bold = true })
hi("htmlH3", { fg = fg, bold = true })
hi("htmlBold", { bold = true })
hi("htmlItalic", { italic = true })
hi("markdownItalic", { italic = true })
hi("@markup.italic", { italic = true })
hi("markdownCode", { fg = gray3, bg = bg })
hi("markdownCodeBlock", { fg = gray3, bg = bg })
hi("markdownListMarker", { fg = accent, bold = true })
hi("markdownLink", { fg = accent })
hi("markdownLinkText", { fg = accent, underline = true })

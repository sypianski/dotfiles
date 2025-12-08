-- eink-soft: Muted pastels, gentle on e-ink
-- Optimized for 4096-color e-ink displays

vim.cmd("highlight clear")
vim.o.background = "light"
vim.g.colors_name = "eink-soft"

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local bg = "#ffffff"
local fg = "#222222"
local gray = "#888888"
local green = "#448844"
local blue = "#446688"
local purple = "#665588"
local red = "#884444"
local orange = "#886644"

-- Editor
hi("Normal", { fg = fg, bg = bg })
hi("NormalFloat", { fg = fg, bg = bg })
hi("FloatBorder", { fg = gray, bg = bg })
hi("Cursor", { fg = bg, bg = fg })
hi("CursorLine", { bg = "#f5f5f5" })
hi("CursorLineNr", { fg = fg, bold = true })
hi("LineNr", { fg = gray })
hi("SignColumn", { bg = bg })
hi("VertSplit", { fg = "#cccccc" })
hi("StatusLine", { fg = fg, bg = bg })
hi("StatusLineNC", { fg = gray, bg = bg })
hi("Pmenu", { fg = fg, bg = bg })
hi("PmenuSel", { fg = bg, bg = blue })
hi("Visual", { bg = "#dddddd" })
hi("Search", { fg = bg, bg = blue })
hi("IncSearch", { fg = bg, bg = fg })
hi("MatchParen", { fg = purple, bold = true, underline = true })

-- Syntax
hi("Comment", { fg = gray, italic = true })
hi("Constant", { fg = purple })
hi("String", { fg = green })
hi("Number", { fg = orange })
hi("Boolean", { fg = purple, bold = true })
hi("Identifier", { fg = fg })
hi("Function", { fg = blue, bold = true })
hi("Statement", { fg = purple })
hi("Keyword", { fg = purple, bold = true })
hi("Operator", { fg = fg })
hi("PreProc", { fg = orange })
hi("Type", { fg = blue })
hi("Special", { fg = orange })
hi("Error", { fg = red, bold = true })
hi("Todo", { fg = orange, bold = true })

-- Diff
hi("DiffAdd", { bg = "#ddffdd" })
hi("DiffChange", { bg = "#ffffdd" })
hi("DiffDelete", { fg = red, bg = "#ffdddd" })
hi("DiffText", { bg = "#ffff99", bold = true })

-- Markdown
hi("htmlH1", { fg = blue, bold = true })
hi("htmlH2", { fg = blue, bold = true })
hi("htmlH3", { fg = blue, bold = true })
hi("htmlBold", { bold = true })
hi("htmlItalic", { italic = true })
hi("markdownItalic", { italic = true })
hi("@markup.italic", { italic = true })
hi("markdownCode", { fg = green, bg = bg })
hi("markdownCodeBlock", { fg = green, bg = bg })
hi("markdownListMarker", { fg = orange, bold = true })
hi("markdownLink", { fg = blue })
hi("markdownLinkText", { fg = blue, underline = true })

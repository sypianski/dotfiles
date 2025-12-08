-- eink-vivid: Stronger colors that pop on e-ink
-- Optimized for 4096-color e-ink displays

vim.cmd("highlight clear")
vim.o.background = "light"
vim.g.colors_name = "eink-vivid"

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local bg = "#ffffff"
local fg = "#000000"
local gray = "#666666"
local green = "#007700"
local blue = "#0044cc"
local purple = "#7700aa"
local red = "#cc0000"
local orange = "#cc6600"
local cyan = "#007788"

-- Editor
hi("Normal", { fg = fg, bg = bg })
hi("NormalFloat", { fg = fg, bg = bg })
hi("FloatBorder", { fg = gray, bg = bg })
hi("Cursor", { fg = bg, bg = fg })
hi("CursorLine", { bg = "#f0f0f0" })
hi("CursorLineNr", { fg = fg, bold = true })
hi("LineNr", { fg = gray })
hi("SignColumn", { bg = bg })
hi("VertSplit", { fg = "#aaaaaa" })
hi("StatusLine", { fg = fg, bg = bg })
hi("StatusLineNC", { fg = gray, bg = bg })
hi("Pmenu", { fg = fg, bg = bg })
hi("PmenuSel", { fg = bg, bg = blue })
hi("Visual", { bg = "#cccccc" })
hi("Search", { fg = bg, bg = orange })
hi("IncSearch", { fg = bg, bg = fg })
hi("MatchParen", { fg = red, bold = true, underline = true })

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
hi("PreProc", { fg = cyan })
hi("Type", { fg = cyan, bold = true })
hi("Special", { fg = red })
hi("Error", { fg = red, bold = true })
hi("Todo", { fg = orange, bold = true })

-- Diff
hi("DiffAdd", { bg = "#ccffcc" })
hi("DiffChange", { bg = "#ffffcc" })
hi("DiffDelete", { fg = red, bg = "#ffcccc" })
hi("DiffText", { bg = "#ffff88", bold = true })

-- Markdown
hi("htmlH1", { fg = blue, bold = true })
hi("htmlH2", { fg = purple, bold = true })
hi("htmlH3", { fg = cyan, bold = true })
hi("htmlBold", { bold = true })
hi("htmlItalic", { italic = true })
hi("markdownItalic", { italic = true })
hi("@markup.italic", { italic = true })
hi("markdownCode", { fg = green, bg = bg })
hi("markdownCodeBlock", { fg = green, bg = bg })
hi("markdownListMarker", { fg = red, bold = true })
hi("markdownLink", { fg = blue })
hi("markdownLinkText", { fg = blue, underline = true })

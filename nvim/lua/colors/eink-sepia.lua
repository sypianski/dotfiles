-- eink-sepia: Warm sepia tones for comfortable reading
-- Optimized for 4096-color e-ink displays

vim.cmd("highlight clear")
vim.o.background = "light"
vim.g.colors_name = "eink-sepia"

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local bg = "#ffffff"
local fg = "#3d3226"
local gray = "#8b7b6b"
local brown = "#6b4423"
local green = "#5a6b3a"
local blue = "#4a5a7a"
local red = "#8b3a3a"
local orange = "#8b6b23"

-- Editor
hi("Normal", { fg = fg, bg = bg })
hi("NormalFloat", { fg = fg, bg = bg })
hi("FloatBorder", { fg = gray, bg = bg })
hi("Cursor", { fg = bg, bg = fg })
hi("CursorLine", { bg = "#f8f4ef" })
hi("CursorLineNr", { fg = fg, bold = true })
hi("LineNr", { fg = gray })
hi("SignColumn", { bg = bg })
hi("VertSplit", { fg = "#d4c9bb" })
hi("StatusLine", { fg = fg, bg = bg })
hi("StatusLineNC", { fg = gray, bg = bg })
hi("Pmenu", { fg = fg, bg = bg })
hi("PmenuSel", { fg = bg, bg = brown })
hi("Visual", { bg = "#e8e0d4" })
hi("Search", { fg = bg, bg = orange })
hi("IncSearch", { fg = bg, bg = fg })
hi("MatchParen", { fg = red, bold = true, underline = true })

-- Syntax
hi("Comment", { fg = gray, italic = true })
hi("Constant", { fg = brown })
hi("String", { fg = green })
hi("Number", { fg = orange })
hi("Boolean", { fg = brown, bold = true })
hi("Identifier", { fg = fg })
hi("Function", { fg = blue, bold = true })
hi("Statement", { fg = brown })
hi("Keyword", { fg = brown, bold = true })
hi("Operator", { fg = fg })
hi("PreProc", { fg = orange })
hi("Type", { fg = blue })
hi("Special", { fg = red })
hi("Error", { fg = red, bold = true })
hi("Todo", { fg = orange, bold = true })

-- Diff
hi("DiffAdd", { bg = "#e0ead4" })
hi("DiffChange", { bg = "#ebe4d0" })
hi("DiffDelete", { fg = red, bg = "#ebd4d4" })
hi("DiffText", { bg = "#e8dc9a", bold = true })

-- Markdown
hi("htmlH1", { fg = brown, bold = true })
hi("htmlH2", { fg = brown, bold = true })
hi("htmlH3", { fg = brown, bold = true })
hi("htmlBold", { bold = true })
hi("htmlItalic", { italic = true })
hi("markdownItalic", { italic = true })
hi("@markup.italic", { italic = true })
hi("markdownCode", { fg = green, bg = bg })
hi("markdownCodeBlock", { fg = green, bg = bg })
hi("markdownListMarker", { fg = orange, bold = true })
hi("markdownLink", { fg = blue })
hi("markdownLinkText", { fg = blue, underline = true })

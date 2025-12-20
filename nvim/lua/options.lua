-- Display settings
vim.opt.fillchars = { eob = " " }
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
vim.opt.shortmess:append("I")

-- Color settings
vim.opt.termguicolors = true
vim.opt.background = "light"
require("colors.eink-clear")

-- Syntax and filetype
vim.cmd([[syntax on]])
vim.cmd([[filetype plugin indent on]])

-- Markdown concealment
vim.opt.conceallevel = 2
vim.g.vim_markdown_conceal = 1
vim.g.vim_markdown_conceal_code_blocks = 0

-- Start with all folds open
vim.opt.foldlevelstart = 99

-- Leader key
vim.g.mapleader = "<Tab>"

-- Clipboard disabled - using keymaps in keymaps.lua instead

-- Abbreviations
vim.cmd("cabbrev tele Telescope")

-- User commands for colorschemes
local function load_eink(name)
  package.loaded["colors." .. name] = nil
  require("colors." .. name)
end
vim.api.nvim_create_user_command("EinkClear", function() load_eink("eink-clear") end, {})
vim.api.nvim_create_user_command("EinkSoft", function() load_eink("eink-soft") end, {})
vim.api.nvim_create_user_command("EinkVivid", function() load_eink("eink-vivid") end, {})
vim.api.nvim_create_user_command("EinkSepia", function() load_eink("eink-sepia") end, {})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load configuration
require("options")
require("lazy").setup("plugins")
require("keymaps")

-- Colorscheme
vim.cmd.colorscheme("vim")

-- Transparent background (match terminal)
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE", ctermbg = "NONE" })

-- Readable comment color
vim.api.nvim_set_hl(0, "Comment", { fg = "grey", ctermfg = "grey" })

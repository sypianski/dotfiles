# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration for Termux (Android). Uses lazy.nvim as the plugin manager.

## Structure

- `init.lua` - Main configuration file (plugin setup, keymaps, options)
- `lua/config/` - Plugin-specific configuration modules

## Plugin Manager

lazy.nvim bootstraps itself automatically on first run. Plugins are defined in `init.lua` within `require("lazy").setup({...})`.

## Key Plugins

- **zen-mode.nvim** - Distraction-free writing mode
- **vim-markdown** - Markdown syntax and concealment
- **substitute.nvim** - Paste without overwriting register, text exchange
- **telescope-frecency.nvim** - Frecency-based file finder
- **persistence.nvim** - Session management
- **wilder.nvim** - Command-line completion

## Important Keymaps

Leader key is `<Space>`.

- `s` / `ss` / visual `s` - Substitute (paste without overwriting register)
- `sx` / `sxx` / visual `sx` - Exchange text regions
- `<leader>fr` - Telescope frecency
- `<leader>ps` - Restore session for current directory
- `<leader>pl` - Restore last session
- `:tele` - Abbreviation for `:Telescope`

## Notes

- Terminal colors mode (`termguicolors = false`) with light background
- Conceallevel 2 for markdown rendering
- Word wrap with breakindent enabled

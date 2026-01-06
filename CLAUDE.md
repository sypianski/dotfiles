# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Overview

This is a home directory (~) on a VPS (hostname: `masawayh`) with dotfiles managed via symlinks from `~/dotfiles/`. The system uses Fish shell with tmux auto-start.

## Dotfiles Management

Dotfiles are stored in `~/dotfiles/` (a regular git repo) and symlinked to their expected locations in `$HOME`.

**Symlink structure:**
```
~/.tmux.conf      -> ~/dotfiles/.tmux.conf
~/fish/           -> ~/dotfiles/fish/
~/nvim/           -> ~/dotfiles/nvim/
~/termux/         -> ~/dotfiles/termux/
~/.termux         -> ~/termux (for Termux app compatibility)
~/CLAUDE.md       -> ~/dotfiles/CLAUDE.md
```

**Working with dotfiles:**
```bash
cd ~/dotfiles
git status
git add <file>
git commit -m "message"
```

## Shell Setup

- **Primary shell:** Fish (auto-launched from .bashrc)
- **Fish config:** `~/fish/config.fish` (symlinked from dotfiles)
- **Tmux:** Auto-starts in interactive Fish sessions; on VPS prepares `tmux attach` command
- **Reload config:** `rikargar` or `source ~/fish/config.fish`

## Tmux

- **Prefix:** `C-n` or `` ` `` (backtick)
- **Copy mode:** Vi-style (`mode-keys vi`)
- **Session chooser:** `prefix + s`
- **Fuzzy finder:** `prefix + f` (tmux-fzf)
- **Status bar:** Shows abbreviated path, RAM/CPU usage, time

## Key Functions & Aliases

**Claude Code:**
- `cc` - Launch Claude Code with `--dangerously-skip-permissions`
- `ccu` / `ccusage` - Token usage monitoring
- `ccul` - Live token usage blocks
- `ccm` - Claude monitor with plan limits
- `claude-videz` - Show Claude sessions with RAM % and tmux window
- `claude-ocidar` - Kill all Claude Code sessions
- `claude-kontar` - Count active Claude sessions

**System Monitoring:**
- `glutoni` / `memoro` - Show RAM/swap and top processes
- `gv` / `glutoni-vido` - Interactive system monitor with graphs (press 1-8 to kill, q to quit)
- `t` - Quick tmux commands (`t` alone opens monitor, `t a/n/k/l` for attach/new/kill/list)
- `mon` - Switch to monitor session (btop)

**Cloud Storage:**
- `muntar-gdrive` / `muntar-dropbox` - Mount cloud drives via rclone
- `sinkronigar on|off|status` / `sync` - Toggle Syncthing

**SSH:**
- `mac`, `vps`, `masawayh` - SSH to various machines

**Theme:**
- `temo <name>` - Theme switcher for Termux/tmux (eink, eink-soft, dark, nocolors)

**Other:**
- `cbr` - Paste Android clipboard to tmux
- `recetageto` - Recipe scraper tool

## Secrets

API keys sourced from `~/.secrets` (not tracked in git).

## Directory Structure

- `~/dotfiles/` - Git repo containing all config files
- `~/utensili/` - Tools and utilities (do not modify without permission)
- `~/vulti/` - Obsidian vaults (sajeco, sse1k, vault1)
- `~/projekti/` - Projects synced with Mac
- `~/mnt/gdrive/`, `~/mnt/dropbox/` - Cloud storage mount points
- `~/.claude/` - Claude Code configuration and state

## Neovim

Config at `~/nvim/` (symlinked from dotfiles). Uses lazy.nvim plugin manager. Leader is `<Space>`. See `~/nvim/CLAUDE.md` for details.

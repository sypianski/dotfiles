# Himalaya Email Setup Notes

## Current Status

| Account | Status | Auth Method |
|---------|--------|-------------|
| gmail | ✅ Working | App password |
| icloud | ✅ Working | App password |
| outlook | ❌ Blocked | Needs OAuth2 (Microsoft locked down public clients) |
| unive | ❌ Blocked | University disabled app passwords, needs OAuth2 |

## What Was Done

1. **Fixed password extraction** - `~/.secrets` uses Fish shell syntax (`set -gx VAR value`), but config used bash-style parsing. Fixed with awk command.

2. **Installed email-oauth2-proxy** - `pipx install emailproxy` with `prompt_toolkit` for interactive auth.

3. **Configured proxy** at `~/.config/emailproxy/emailproxy.config`:
   - Outlook: ports 1993 (IMAP), 1587 (SMTP)
   - Unive: ports 2993 (IMAP), 2465 (SMTP)

4. **Updated himalaya config** - outlook and unive accounts point to localhost proxy with `encryption.type = "none"`.

## Blocking Issues

### Outlook
- Thunderbird's public client ID (`9e5f94bc-...`) has restricted redirect URIs
- Microsoft Office client ID (`d3590ed6-...`) not enabled for consumer accounts
- **Solution**: Create custom Azure app or use app password if available

### Unive (Google Workspace)
- University (Ca' Foscari) has disabled app passwords for students
- Need OAuth2 with a registered Google Cloud app
- The client ID in config (`406964657835-...`) is from isstrern email tools - may work

## Files Modified

- `~/.config/himalaya/config.toml` - main himalaya config
- `~/.config/emailproxy/emailproxy.config` - OAuth2 proxy config
- `~/.secrets` - contains app passwords (Fish syntax)

## Commands

```bash
# Start proxy (run in separate tmux pane)
emailproxy --no-gui --external-auth --config-file ~/.config/emailproxy/emailproxy.config

# Test accounts
himalaya envelope list -a gmail -s 3
himalaya envelope list -a icloud -s 3
himalaya envelope list -a outlook -s 3  # needs proxy running
himalaya envelope list -a unive -s 3    # needs proxy running
```

## Email Triage Workflow

Standard workflow for cleaning up emails:

1. **Gather** - List all potentially unwanted emails
2. **Present** - Show multi-select options (delete/archive/add to todo)
3. **Select** - User picks which actions to take
4. **Batch execute** - Perform all actions at once

Actions available:
- **Delete** - Move to trash
- **Archive** - Move to archive folder
- **Todo + Archive** - Add task to Obsidian `todo.md`, then archive email

## To Resume

See `todo.md` in this folder.

# Himalaya Setup TODO

## Outlook Account

Options (pick one):

- [ ] **Option A: Create Azure App** (recommended)
  1. Go to https://portal.azure.com → Azure Active Directory → App registrations
  2. New registration → Name: "Himalaya Email" → Personal Microsoft accounts only
  3. Add redirect URI: `http://localhost`
  4. Copy Application (client) ID
  5. Update `~/.config/emailproxy/emailproxy.config` with new client_id

- [ ] **Option B: Try App Password**
  1. Go to https://account.microsoft.com → Security → Advanced security options
  2. If "App passwords" section exists, create one
  3. Update `~/.secrets` with `set -gx OUTLOOK_APP_PASSWORD <password>`
  4. Revert himalaya config to direct connection (not proxy)

- [ ] **Option C: Skip Outlook** - just don't use it with himalaya

## Unive Account

- [ ] **Try existing Google OAuth** - the client ID in proxy config might work
  1. Start proxy: `emailproxy --no-gui --external-auth --config-file ~/.config/emailproxy/emailproxy.config`
  2. Trigger: `himalaya envelope list -a unive -s 1`
  3. If auth URL appears, complete OAuth flow in browser

- [ ] **If blocked**: Need to create Google Cloud project with OAuth consent screen

## Optional Improvements

- [ ] Create systemd user service for emailproxy auto-start
- [ ] Add himalaya to Fish shell aliases

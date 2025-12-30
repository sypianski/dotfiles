#!/usr/bin/env python3
"""
Outlook OAuth2 token manager for himalaya.
Usage:
    outlook-oauth.py setup     - First-time authorization (opens browser)
    outlook-oauth.py token     - Get current access token (auto-refreshes)
    outlook-oauth.py status    - Check token status
"""

import json
import sys
import os
import time
import hashlib
import base64
import secrets
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlencode, parse_qs, urlparse
import urllib.request
import urllib.error

# Configuration - YOU MUST SET THESE after registering your Azure app
CONFIG_DIR = os.path.expanduser("~/.config/himalaya")
TOKEN_FILE = os.path.join(CONFIG_DIR, "outlook-tokens.json")
CLIENT_ID_FILE = os.path.join(CONFIG_DIR, "outlook-client-id")

# Microsoft OAuth2 endpoints
AUTH_URL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize"
TOKEN_URL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token"

# Scopes for IMAP and SMTP
SCOPES = [
    "https://outlook.office.com/IMAP.AccessAsUser.All",
    "https://outlook.office.com/SMTP.Send",
    "offline_access",
]

REDIRECT_URI = "http://localhost:8400/callback"


def get_client_id():
    """Read client ID from file."""
    if not os.path.exists(CLIENT_ID_FILE):
        print(f"Error: Client ID not found. Create {CLIENT_ID_FILE} with your Azure app client ID.", file=sys.stderr)
        sys.exit(1)
    with open(CLIENT_ID_FILE) as f:
        return f.read().strip()


def generate_pkce():
    """Generate PKCE code verifier and challenge."""
    verifier = secrets.token_urlsafe(64)[:128]
    challenge = base64.urlsafe_b64encode(
        hashlib.sha256(verifier.encode()).digest()
    ).decode().rstrip("=")
    return verifier, challenge


def load_tokens():
    """Load tokens from file."""
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE) as f:
            return json.load(f)
    return None


def save_tokens(tokens):
    """Save tokens to file."""
    tokens["saved_at"] = time.time()
    with open(TOKEN_FILE, "w") as f:
        json.dump(tokens, f, indent=2)
    os.chmod(TOKEN_FILE, 0o600)


def refresh_token(tokens):
    """Refresh the access token using refresh token."""
    client_id = get_client_id()

    data = urlencode({
        "client_id": client_id,
        "grant_type": "refresh_token",
        "refresh_token": tokens["refresh_token"],
        "scope": " ".join(SCOPES),
    }).encode()

    req = urllib.request.Request(TOKEN_URL, data=data, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")

    try:
        with urllib.request.urlopen(req) as response:
            new_tokens = json.loads(response.read().decode())
            save_tokens(new_tokens)
            return new_tokens
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"Token refresh failed: {error_body}", file=sys.stderr)
        sys.exit(1)


def is_token_expired(tokens):
    """Check if access token is expired (with 5 min buffer)."""
    if "saved_at" not in tokens or "expires_in" not in tokens:
        return True
    expires_at = tokens["saved_at"] + tokens["expires_in"] - 300
    return time.time() > expires_at


def get_access_token():
    """Get current access token, refreshing if needed."""
    tokens = load_tokens()
    if not tokens:
        print("No tokens found. Run: outlook-oauth.py setup", file=sys.stderr)
        sys.exit(1)

    if is_token_expired(tokens):
        tokens = refresh_token(tokens)

    return tokens["access_token"]


class CallbackHandler(BaseHTTPRequestHandler):
    """HTTP handler to receive OAuth callback."""

    auth_code = None

    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)

        if "code" in query:
            CallbackHandler.auth_code = query["code"][0]
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(b"<html><body><h1>Authorization successful!</h1><p>You can close this window.</p></body></html>")
        elif "error" in query:
            self.send_response(400)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            error = query.get("error", ["unknown"])[0]
            desc = query.get("error_description", [""])[0]
            self.wfile.write(f"<html><body><h1>Error: {error}</h1><p>{desc}</p></body></html>".encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Suppress logging


def do_setup():
    """Perform initial OAuth2 authorization."""
    client_id = get_client_id()
    verifier, challenge = generate_pkce()

    params = {
        "client_id": client_id,
        "response_type": "code",
        "redirect_uri": REDIRECT_URI,
        "scope": " ".join(SCOPES),
        "response_mode": "query",
        "code_challenge": challenge,
        "code_challenge_method": "S256",
    }

    auth_url = f"{AUTH_URL}?{urlencode(params)}"

    print("Opening browser for authorization...")
    print(f"If browser doesn't open, visit:\n{auth_url}\n")
    webbrowser.open(auth_url)

    # Start local server to receive callback
    server = HTTPServer(("localhost", 8400), CallbackHandler)
    server.timeout = 120

    print("Waiting for authorization (timeout: 2 minutes)...")
    while CallbackHandler.auth_code is None:
        server.handle_request()
        if CallbackHandler.auth_code is None:
            print("Timeout waiting for authorization.", file=sys.stderr)
            sys.exit(1)

    # Exchange code for tokens
    data = urlencode({
        "client_id": client_id,
        "grant_type": "authorization_code",
        "code": CallbackHandler.auth_code,
        "redirect_uri": REDIRECT_URI,
        "code_verifier": verifier,
    }).encode()

    req = urllib.request.Request(TOKEN_URL, data=data, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")

    try:
        with urllib.request.urlopen(req) as response:
            tokens = json.loads(response.read().decode())
            save_tokens(tokens)
            print("Authorization successful! Tokens saved.")
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"Token exchange failed: {error_body}", file=sys.stderr)
        sys.exit(1)


def show_status():
    """Show token status."""
    tokens = load_tokens()
    if not tokens:
        print("No tokens found. Run: outlook-oauth.py setup")
        return

    saved_at = tokens.get("saved_at", 0)
    expires_in = tokens.get("expires_in", 0)
    expires_at = saved_at + expires_in

    print(f"Token saved: {time.ctime(saved_at)}")
    print(f"Expires at: {time.ctime(expires_at)}")
    print(f"Expired: {is_token_expired(tokens)}")
    print(f"Has refresh token: {'refresh_token' in tokens}")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "setup":
        do_setup()
    elif cmd == "token":
        print(get_access_token())
    elif cmd == "status":
        show_status()
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Google OAuth2 token manager for Unive (Google Workspace).
Usage:
    unive-oauth.py setup     - First-time authorization
    unive-oauth.py token     - Get current access token
    unive-oauth.py status    - Check token status
"""

import json
import sys
import os
import time
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlencode, parse_qs, urlparse
import urllib.request
import urllib.error

CONFIG_DIR = os.path.expanduser("~/.config/himalaya")
TOKEN_FILE = os.path.join(CONFIG_DIR, "unive-tokens.json")

# Google OAuth2 endpoints
AUTH_URL = "https://accounts.google.com/o/oauth2/auth"
TOKEN_URL = "https://oauth2.googleapis.com/token"

# From emailproxy config - or create your own at console.cloud.google.com
CLIENT_ID = "406964657835-aq8lmia8j95dhl1a2bvharmfk3t1hgqj.apps.googleusercontent.com"
CLIENT_SECRET = "kSmqreRr0qwBWJgbf5Y-PjSU"

# Scopes for Gmail IMAP/SMTP
SCOPES = ["https://mail.google.com/"]

REDIRECT_URI = "http://localhost:8401/callback"


def load_tokens():
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE) as f:
            return json.load(f)
    return None


def save_tokens(tokens):
    tokens["saved_at"] = time.time()
    with open(TOKEN_FILE, "w") as f:
        json.dump(tokens, f, indent=2)
    os.chmod(TOKEN_FILE, 0o600)


def refresh_token(tokens):
    data = urlencode({
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "refresh_token",
        "refresh_token": tokens["refresh_token"],
    }).encode()

    req = urllib.request.Request(TOKEN_URL, data=data, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")

    try:
        with urllib.request.urlopen(req) as response:
            new_tokens = json.loads(response.read().decode())
            # Keep refresh_token if not returned
            if "refresh_token" not in new_tokens:
                new_tokens["refresh_token"] = tokens["refresh_token"]
            save_tokens(new_tokens)
            return new_tokens
    except urllib.error.HTTPError as e:
        print(f"Token refresh failed: {e.read().decode()}", file=sys.stderr)
        sys.exit(1)


def is_token_expired(tokens):
    if "saved_at" not in tokens or "expires_in" not in tokens:
        return True
    expires_at = tokens["saved_at"] + tokens["expires_in"] - 300
    return time.time() > expires_at


def get_access_token():
    tokens = load_tokens()
    if not tokens:
        print("No tokens found. Run: unive-oauth.py setup", file=sys.stderr)
        sys.exit(1)

    if is_token_expired(tokens):
        tokens = refresh_token(tokens)

    return tokens["access_token"]


class CallbackHandler(BaseHTTPRequestHandler):
    auth_code = None

    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)

        if "code" in query:
            CallbackHandler.auth_code = query["code"][0]
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(b"<html><body><h1>OK!</h1><p>Mozesz zamknac okno.</p></body></html>")
        elif "error" in query:
            self.send_response(400)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            error = query.get("error", ["unknown"])[0]
            self.wfile.write(f"<html><body><h1>Error: {error}</h1></body></html>".encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass


def do_setup():
    params = {
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "scope": " ".join(SCOPES),
        "response_type": "code",
        "access_type": "offline",
        "prompt": "consent",
    }

    auth_url = f"{AUTH_URL}?{urlencode(params)}"

    print("Opening browser for authorization...")
    print(f"If browser doesn't open, visit:\n{auth_url}\n")
    webbrowser.open(auth_url)

    server = HTTPServer(("localhost", 8401), CallbackHandler)
    server.timeout = 120

    print("Waiting for authorization...")
    while CallbackHandler.auth_code is None:
        server.handle_request()
        if CallbackHandler.auth_code is None:
            print("Timeout.", file=sys.stderr)
            sys.exit(1)

    # Exchange code for tokens
    data = urlencode({
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": CallbackHandler.auth_code,
        "redirect_uri": REDIRECT_URI,
    }).encode()

    req = urllib.request.Request(TOKEN_URL, data=data, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")

    try:
        with urllib.request.urlopen(req) as response:
            tokens = json.loads(response.read().decode())
            save_tokens(tokens)
            print("Authorization successful! Tokens saved.")
    except urllib.error.HTTPError as e:
        print(f"Token exchange failed: {e.read().decode()}", file=sys.stderr)
        sys.exit(1)


def show_status():
    tokens = load_tokens()
    if not tokens:
        print("No tokens found. Run: unive-oauth.py setup")
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
        sys.exit(1)


if __name__ == "__main__":
    main()

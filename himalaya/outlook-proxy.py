#!/usr/bin/env python3
"""
Minimal IMAP/SMTP proxy for Outlook OAuth2.
Uses tokens from outlook-oauth.py.
"""

import socket
import ssl
import base64
import threading
import subprocess
import sys

IMAP_LOCAL_PORT = 1993
SMTP_LOCAL_PORT = 1587
OUTLOOK_IMAP = ("outlook.office365.com", 993)
OUTLOOK_SMTP = ("smtp.office365.com", 587)
USER = "sypianski@outlook.com"

def get_token():
    """Get access token from outlook-oauth.py"""
    result = subprocess.run(
        [sys.executable, "/home/yaqub/.config/himalaya/outlook-oauth.py", "token"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise Exception(f"Token error: {result.stderr}")
    return result.stdout.strip()

def xoauth2_string(user, token):
    """Build XOAUTH2 auth string"""
    auth = f"user={user}\x01auth=Bearer {token}\x01\x01"
    return base64.b64encode(auth.encode()).decode()

def handle_imap(client_sock):
    """Handle IMAP connection"""
    try:
        # Connect to Outlook
        ctx = ssl.create_default_context()
        server_sock = ctx.wrap_socket(socket.socket(), server_hostname=OUTLOOK_IMAP[0])
        server_sock.connect(OUTLOOK_IMAP)

        # Read server greeting
        greeting = server_sock.recv(4096)
        client_sock.send(greeting)
        print(f"[IMAP] Sent greeting")

        authenticated = False

        while True:
            data = client_sock.recv(4096)
            if not data:
                break

            line = data.decode('utf-8', errors='replace').strip()
            line_upper = line.upper()
            print(f"[IMAP] Client: {line[:80]}")

            # Intercept any auth attempt and use XOAUTH2 instead
            if (' LOGIN ' in line_upper or 'AUTHENTICATE' in line_upper) and not authenticated:
                tag = line.split()[0]
                try:
                    token = get_token()
                    auth_string = xoauth2_string(USER, token)
                    server_sock.send(f"{tag} AUTHENTICATE XOAUTH2 {auth_string}\r\n".encode())
                    response = server_sock.recv(4096)
                    print(f"[IMAP] Auth response: {response[:100]}")
                    client_sock.send(response)
                    if b'OK' in response:
                        authenticated = True
                        print(f"[IMAP] Authenticated!")
                except Exception as e:
                    print(f"[IMAP] Auth error: {e}")
                    client_sock.send(f"{tag} NO Authentication failed: {e}\r\n".encode())
                continue

            # Forward other commands
            tag = line.split()[0] if line else b""
            server_sock.send(data)
            # Read until we get the tagged response
            full_response = b""
            while True:
                chunk = server_sock.recv(65536)
                if not chunk:
                    break
                full_response += chunk
                # Check if response is complete (ends with tagged response)
                if tag.encode() in full_response and b"\r\n" in full_response[full_response.rfind(tag.encode()):]:
                    break
            print(f"[IMAP] Response: {len(full_response)} bytes")
            client_sock.send(full_response)

    except Exception as e:
        print(f"IMAP error: {e}")
    finally:
        client_sock.close()
        try:
            server_sock.close()
        except:
            pass

def handle_smtp(client_sock):
    """Handle SMTP connection"""
    try:
        # Connect to Outlook
        server_sock = socket.socket()
        server_sock.connect(OUTLOOK_SMTP)

        # Read greeting
        greeting = server_sock.recv(4096)
        client_sock.send(greeting)

        # EHLO exchange
        data = client_sock.recv(4096)
        server_sock.send(data)
        response = server_sock.recv(4096)
        client_sock.send(response)

        # STARTTLS
        client_sock.recv(4096)  # STARTTLS from client
        server_sock.send(b"STARTTLS\r\n")
        response = server_sock.recv(4096)
        client_sock.send(response)

        # Upgrade to TLS
        ctx = ssl.create_default_context()
        server_sock = ctx.wrap_socket(server_sock, server_hostname=OUTLOOK_SMTP[0])

        # EHLO again
        data = client_sock.recv(4096)
        server_sock.send(data)
        response = server_sock.recv(4096)
        client_sock.send(response)

        authenticated = False

        while True:
            data = client_sock.recv(4096)
            if not data:
                break

            line = data.decode('utf-8', errors='replace').strip().upper()

            # Intercept AUTH and use XOAUTH2
            if line.startswith('AUTH') and not authenticated:
                try:
                    token = get_token()
                    auth_string = xoauth2_string(USER, token)
                    server_sock.send(f"AUTH XOAUTH2 {auth_string}\r\n".encode())
                    response = server_sock.recv(4096)
                    client_sock.send(response)
                    if b'235' in response:
                        authenticated = True
                except Exception as e:
                    client_sock.send(f"535 Auth failed: {e}\r\n".encode())
                continue

            server_sock.send(data)
            response = server_sock.recv(65536)
            if response:
                client_sock.send(response)

    except Exception as e:
        print(f"SMTP error: {e}")
    finally:
        client_sock.close()
        try:
            server_sock.close()
        except:
            pass

def run_server(port, handler, name):
    """Run a proxy server"""
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('127.0.0.1', port))
    server.listen(5)
    print(f"{name} proxy listening on 127.0.0.1:{port}")

    while True:
        client, addr = server.accept()
        threading.Thread(target=handler, args=(client,), daemon=True).start()

def main():
    print("Starting Outlook OAuth2 proxy...")

    # Test token first
    try:
        token = get_token()
        print(f"Token OK ({len(token)} chars)")
    except Exception as e:
        print(f"Token error: {e}")
        sys.exit(1)

    # Start servers
    threading.Thread(target=run_server, args=(IMAP_LOCAL_PORT, handle_imap, "IMAP"), daemon=True).start()
    threading.Thread(target=run_server, args=(SMTP_LOCAL_PORT, handle_smtp, "SMTP"), daemon=True).start()

    print("Proxy running. Press Ctrl+C to stop.")
    try:
        while True:
            threading.Event().wait(1)
    except KeyboardInterrupt:
        print("\nStopping...")

if __name__ == "__main__":
    main()

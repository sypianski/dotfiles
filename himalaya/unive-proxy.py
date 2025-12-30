#!/usr/bin/env python3
"""
Minimal IMAP/SMTP proxy for Unive (Google Workspace) OAuth2.
"""

import socket
import ssl
import base64
import threading
import subprocess
import sys

IMAP_LOCAL_PORT = 2993
SMTP_LOCAL_PORT = 2465
GOOGLE_IMAP = ("imap.gmail.com", 993)
GOOGLE_SMTP = ("smtp.gmail.com", 465)
USER = "jakub.sypianski@unive.it"

def get_token():
    result = subprocess.run(
        [sys.executable, "/home/yaqub/.config/himalaya/unive-oauth.py", "token"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise Exception(f"Token error: {result.stderr}")
    return result.stdout.strip()

def xoauth2_string(user, token):
    auth = f"user={user}\x01auth=Bearer {token}\x01\x01"
    return base64.b64encode(auth.encode()).decode()

def handle_imap(client_sock):
    try:
        ctx = ssl.create_default_context()
        server_sock = ctx.wrap_socket(socket.socket(), server_hostname=GOOGLE_IMAP[0])
        server_sock.connect(GOOGLE_IMAP)

        greeting = server_sock.recv(4096)
        client_sock.send(greeting)

        authenticated = False

        while True:
            data = client_sock.recv(4096)
            if not data:
                break

            line = data.decode('utf-8', errors='replace').strip()
            line_upper = line.upper()

            if (' LOGIN ' in line_upper or 'AUTHENTICATE' in line_upper) and not authenticated:
                tag = line.split()[0]
                try:
                    token = get_token()
                    auth_string = xoauth2_string(USER, token)
                    server_sock.send(f"{tag} AUTHENTICATE XOAUTH2 {auth_string}\r\n".encode())
                    response = server_sock.recv(4096)
                    client_sock.send(response)
                    if b'OK' in response:
                        authenticated = True
                except Exception as e:
                    client_sock.send(f"{tag} NO Authentication failed: {e}\r\n".encode())
                continue

            tag = line.split()[0] if line else ""
            server_sock.send(data)
            full_response = b""
            while True:
                chunk = server_sock.recv(65536)
                if not chunk:
                    break
                full_response += chunk
                if tag.encode() in full_response and b"\r\n" in full_response[full_response.rfind(tag.encode()):]:
                    break
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
    try:
        ctx = ssl.create_default_context()
        server_sock = ctx.wrap_socket(socket.socket(), server_hostname=GOOGLE_SMTP[0])
        server_sock.connect(GOOGLE_SMTP)

        greeting = server_sock.recv(4096)
        client_sock.send(greeting)

        authenticated = False

        while True:
            data = client_sock.recv(4096)
            if not data:
                break

            line = data.decode('utf-8', errors='replace').strip()
            line_upper = line.upper()

            if line_upper.startswith('AUTH') and not authenticated:
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
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('127.0.0.1', port))
    server.listen(5)
    print(f"{name} proxy on 127.0.0.1:{port}")

    while True:
        client, addr = server.accept()
        threading.Thread(target=handler, args=(client,), daemon=True).start()

def main():
    print("Unive OAuth2 proxy starting...")
    try:
        token = get_token()
        print(f"Token OK ({len(token)} chars)")
    except Exception as e:
        print(f"Token error: {e}")
        sys.exit(1)

    threading.Thread(target=run_server, args=(IMAP_LOCAL_PORT, handle_imap, "IMAP"), daemon=True).start()
    threading.Thread(target=run_server, args=(SMTP_LOCAL_PORT, handle_smtp, "SMTP"), daemon=True).start()

    print("Proxy running.")
    try:
        while True:
            threading.Event().wait(1)
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    main()

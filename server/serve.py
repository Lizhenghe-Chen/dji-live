#!/usr/bin/env python3
# Zero-dependency static server for the DJI live page (macOS)
# Uses only the Python standard library (bundled with macOS).
# Usage: python3 serve.py <dir> <port>

import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer



def load_page():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    try:
        port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
    except ValueError:
        raise ValueError("port must be an integer") from None

    if not 1 <= port <= 65535:
        raise ValueError("port must be between 1 and 65535")

    with open(os.path.join(root, "index.html"), "rb") as page:
        return port, page.read()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(html)))
        self.end_headers()
        self.wfile.write(html)

    def log_message(self, *args):
        pass


try:
    port, html = load_page()
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()
except (OSError, ValueError) as error:
    print(f"serve.py: {error}", file=sys.stderr)
    sys.exit(1)

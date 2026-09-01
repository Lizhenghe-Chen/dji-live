#!/usr/bin/env python3
# Zero-dependency static server for the DJI live page (macOS)
# Uses only the Python standard library (bundled with macOS).
# Usage: python3 serve.py <dir> <port>

import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
html = open(os.path.join(root, "index.html"), "rb").read()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(html)))
        self.end_headers()
        self.wfile.write(html)

    def log_message(self, *args):
        pass


HTTPServer(("0.0.0.0", port), Handler).serve_forever()

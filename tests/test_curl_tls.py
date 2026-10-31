#!/usr/bin/env python3
"""Check HTTPS verification with the locked curl in an isolated local server."""
import http.server
import os
from pathlib import Path
import ssl
import subprocess
import tempfile
import threading


class Handler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Length", "12")
        self.end_headers()
        self.wfile.write(b"curl fixture")

    def log_message(self, format, *args):
        pass


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    config = root / "openssl.cnf"
    config.write_text(
        "[req]\ndistinguished_name = dn\nx509_extensions = extensions\n"
        "[dn]\n[extensions]\nsubjectAltName = DNS:localhost\n"
    )
    cert, key = root / "cert.pem", root / "key.pem"
    subprocess.run(
        ["/usr/bin/openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes",
         "-keyout", str(key), "-out", str(cert), "-days", "1", "-subj",
         "/CN=localhost", "-config", str(config)],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(cert, key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    url = f"https://localhost:{server.server_port}/"
    env = os.environ.copy()
    for key_name in ("CURL_CA_BUNDLE", "SSL_CERT_FILE", "SSL_CERT_DIR"):
        env.pop(key_name, None)
    version = subprocess.run(["curl", "--version"], env=env, capture_output=True, check=True)
    assert b"AppleSecTrust" in version.stdout
    args = ["curl", "--silent", "--show-error", "--noproxy", "*", "--max-time", "5"]
    try:
        rejected = subprocess.run(args + [url], env=env, capture_output=True)
        assert rejected.returncode == 60, f"untrusted certificate returned {rejected.returncode}"
        accepted = subprocess.run(args + ["--cacert", str(cert), url], env=env, capture_output=True)
        assert accepted.returncode == 0, accepted.stderr.decode()
        assert accepted.stdout == b"curl fixture"
    finally:
        server.shutdown()
        server.server_close()
        thread.join()
print("ok - locked curl rejects untrusted TLS and accepts the specified CA")

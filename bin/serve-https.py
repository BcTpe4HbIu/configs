#!/bin/env python3
import logging
import ssl
from http.server import HTTPServer, SimpleHTTPRequestHandler
from tempfile import NamedTemporaryFile

from cert_generator import CertificateGenerator

logging.basicConfig(level=logging.INFO)

generator = CertificateGenerator(cn="Local certificate", country="RU")

cert_file = NamedTemporaryFile()
key_file = NamedTemporaryFile()

try:
    generator.generate()
    generator.dump_key(key_file)
    generator.dump_object(cert_file)
    key_file.flush()
    cert_file.flush()
except:
    cert_file.close()
    key_file.close()
    raise

try:
    context = ssl.SSLContext(ssl.PROTOCOL_TLS)
    context.verify_mode = ssl.CERT_NONE
    context.load_cert_chain(cert_file.name, key_file.name)
finally:
    cert_file.close()
    key_file.close()

logging.getLogger().info("Serving on https://localhost:4443")
httpd = HTTPServer(('localhost', 4443), SimpleHTTPRequestHandler)
httpd.socket = context.wrap_socket(
    sock=httpd.socket, server_side=True
)
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    pass

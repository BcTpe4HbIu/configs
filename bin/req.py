#!/usr/bin/python
import argparse
from OpenSSL import crypto
import logging


def generateKey(type, bits):
    key = crypto.PKey()
    key.generate_key(type, bits)
    return key


def generateRequest(key, cn, email=None, country=None, state=None, locality=None, org=None, ou=None, alt=None):
    x509_extensions = ([
        crypto.X509Extension(b"keyUsage", False, b"Digital Signature, Non Repudiation, Key Encipherment"),
        crypto.X509Extension(b"basicConstraints", False, b"CA:FALSE"),
    ])

    sans = []
    if alt:
        for i in alt:
            sans.append("DNS: %s" % i)
        sans_str = ", ".join(sans)
        sans_bytes = bytes(sans_str, 'utf8')
        x509_extensions.append(crypto.X509Extension(b"subjectAltName", False, sans_bytes))

    req = crypto.X509Req()
    subj = req.get_subject()
    subj.CN = cn
    if email:
        subj.emailAddress = email
    if country:
        subj.countryName = country
    if state:
        subj.stateOrProvinceName = state
    if locality:
        subj.localityName = locality
    if org:
        subj.organizationName = org
    if ou:
        subj.organizationalUnitName = ou
    req.add_extensions(x509_extensions)
    req.set_pubkey(key)
    req.sign(key, "sha256")

    return req


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    parser = argparse.ArgumentParser(description="Create certificate")
    parser.add_argument("common_name")
    parser.add_argument("keyout", help='Key file name', type=argparse.FileType('bx'))
    parser.add_argument("reqout", help='Request file name', type=argparse.FileType('bx'))
    parser.add_argument("--email")
    parser.add_argument("--country", default="RU")
    parser.add_argument("--state")
    parser.add_argument("--locality")
    parser.add_argument("--org")
    parser.add_argument("--ou")
    parser.add_argument("--alt", action='append', help='DNS ALT names')
    parser.add_argument("--keytype", default='rsa', help='Key type (rsa,dsa)', choices=['rsa', 'dsa'])
    parser.add_argument("--keylen", default=2048, help='Key length (2048)', type=int)

    args = parser.parse_args()

    logging.info("Generating key...")
    if args.keytype == "rsa":
        keytype = crypto.TYPE_RSA
    elif args.keytype == "dsa":
        logging.warning("Using dsa key is not recommended!")
        keytype = crypto.TYPE_DSA
    key = generateKey(keytype, args.keylen)
    logging.info("Generating request...")
    req = generateRequest(key, args.common_name, email=args.email, country=args.country, state=args.state,
                          locality=args.locality, org=args.org, ou=args.ou, alt=args.alt)
    logging.info("Writing out key...")
    args.keyout.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, key))
    logging.info("Writing out request...")
    args.reqout.write(crypto.dump_certificate_request(crypto.FILETYPE_PEM, req))
    logging.info("Done.")

if __name__ == "__main__":
    main()

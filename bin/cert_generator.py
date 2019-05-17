#!/usr/bin/python
import logging
import sys
from abc import ABC, abstractmethod
from typing import List

import click
from OpenSSL import crypto


class X509Creator(ABC):
    def __init__(self, cn: str, email: str = None, country: str = None, state: str = None, locality: str = None,
                 org: str = None, ou: str = None, alt: List = None, key_type: str = 'rsa', key_size: int = 2048,
                 self_singed: bool = False):
        self._self_singed = self_singed
        self._key_size = key_size
        self._key_type = key_type
        self._ou = ou
        self._org = org
        self._locality = locality
        self._state = state
        self._country = country
        self._email = email
        self._cn = cn
        self._alt = alt

        self._key = None
        self._object = None

        self._x509_extensions = list()

    def _generate_key(self):

        if self._key_type == "rsa":
            keytype = crypto.TYPE_RSA
        elif self._key_type == "dsa":
            logging.warning("Using dsa key is not recommended!")
            keytype = crypto.TYPE_DSA
        else:
            logging.error('Unknown key type %s', self._key_type)
            sys.exit(1)
        logging.info('Generating %s key with %s bits', self._key_type, self._key_size)
        self._key = crypto.PKey()
        self._key.generate_key(keytype, self._key_size)

    def _apply_key(self):
        if self._object:
            if not self._key:
                self._generate_key()
            logging.info('Applying key')
            self._object.set_pubkey(self._key)
            self._object.sign(self._key, "sha256")

    def load_key(self, content: str, passphrase: str = None):
        logging.info('Loading existing private key')
        self._key = crypto.load_privatekey(crypto.FILETYPE_PEM, content, passphrase=passphrase)

    def _fill_subject(self):
        logging.info('Filling subject')
        subj = self._object.get_subject()
        subj.CN = self._cn
        if self._email:
            subj.emailAddress = self._email
        if self._country:
            subj.countryName = self._country
        if self._state:
            subj.stateOrProvinceName = self._state
        if self._locality:
            subj.localityName = self._locality
        if self._org:
            subj.organizationName = self._org
        if self._ou:
            subj.organizationalUnitName = self._ou
        logging.info('Resulting subject: %s', subj.get_components())

    def _fill_extensions(self):
        logging.info('Filling extensions')
        x509_extensions = self._x509_extensions

        if self._alt:
            sans = []
            for i in self._alt:
                logging.info('Adding SAN %s', i)
                sans.append("DNS: %s" % i)
            sans_str = ", ".join(sans)
            sans_bytes = bytes(sans_str, 'utf8')
            x509_extensions.append(crypto.X509Extension(b"subjectAltName", False, sans_bytes))

        if x509_extensions:
            self._object.add_extensions(x509_extensions)

    @abstractmethod
    def generate(self):
        """
        Must fill self._object first
        :return:
        """

        self._fill_subject()
        self._fill_extensions()
        self._apply_key()

    def dump_key(self, file):
        logging.info('Writing out private key')
        content = crypto.dump_privatekey(crypto.FILETYPE_PEM, self._key)
        file.write(content)

    def dump_object(self, file):
        logging.info('Writing out object')
        if isinstance(self._object, crypto.X509Req):
            content = crypto.dump_certificate_request(crypto.FILETYPE_PEM, self._object)
        else:
            content = crypto.dump_certificate(crypto.FILETYPE_PEM, self._object)
        file.write(content)


class RequestGenerator(X509Creator):
    def generate(self):
        self._object = crypto.X509Req()
        super(RequestGenerator, self).generate()


class CertificateGenerator(X509Creator):
    def __init__(self, *args, **kwargs):
        super(CertificateGenerator, self).__init__(*args, **kwargs)
        self._x509_extensions = ([
            crypto.X509Extension(b"keyUsage", False, b"Digital Signature,Non Repudiation,Key Encipherment"),
            crypto.X509Extension(b"basicConstraints", False, b"CA:FALSE"),
        ])

    def generate(self):
        self._object = crypto.X509()
        super(CertificateGenerator, self).generate()
        self._object.set_serial_number(1000)
        self._object.gmtime_adj_notBefore(0)
        self._object.gmtime_adj_notAfter(10 * 365 * 24 * 60 * 60)
        self._object.set_issuer(self._object.get_subject())


@click.command()
@click.argument('common_name')
@click.argument('out', type=click.File('bx'))
@click.option('--keyout', type=click.File('bx'))
@click.option('--key', type=click.File('rb'))
@click.option('--email')
@click.option('--country', default='RU')
@click.option('--state')
@click.option('--locality')
@click.option('--org')
@click.option('--ou')
@click.option('--selfsigned', is_flag=True)
@click.option('--keytype', default='rsa', type=click.STRING)
@click.option('--keysize', default=2048, type=click.INT)
@click.option('--alt', multiple=True)
def cli(common_name, out, keyout, key, email, country, state, locality, org, ou, selfsigned, keytype, keysize, alt):
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    kwargs = dict(cn=common_name, email=email, country=country, state=state, locality=locality,
                  org=org, ou=ou, alt=alt, key_type=keytype, key_size=keysize)
    if selfsigned:
        generator = CertificateGenerator(**kwargs)
    else:
        generator = RequestGenerator(**kwargs)

    if key:
        generator.load_key(key.read())
    elif keyout is None:
        logging.error('Must provide key or keyout!')

    generator.generate()
    if key is None:
        generator.dump_key(keyout)
    generator.dump_object(out)


if __name__ == "__main__":
    cli()

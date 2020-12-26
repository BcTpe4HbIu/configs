#!/usr/bin/python
import datetime
import logging
from abc import ABC, abstractmethod
from typing import List, Optional

import click
from cryptography import x509
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateKeyWithSerialization
from cryptography.x509.base import CertificateSigningRequest, Certificate
from cryptography.x509.oid import NameOID


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

        self._key = None  # type: Optional[RSAPrivateKeyWithSerialization]
        self._subject = None  # type: Optional[x509.Name]

        self._x509_extensions = list()

    def _generate_key(self):
        logging.info('Generating RSA key with %s bits', self._key_size)
        self._key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=self._key_size,
        )

    def load_key(self, content: bytes, passphrase: str = None):
        logging.info('Loading existing private key')
        self._key = serialization.load_pem_private_key(content, password=passphrase)

    def _make_subject(self):
        logging.info('Filling subject')
        attr_var_map = [
            (NameOID.COMMON_NAME, self._cn),
            (NameOID.COUNTRY_NAME, self._country),
            (NameOID.STATE_OR_PROVINCE_NAME, self._state),
            (NameOID.LOCALITY_NAME, self._locality),
            (NameOID.ORGANIZATION_NAME, self._org),
            (NameOID.EMAIL_ADDRESS, self._email),
            (NameOID.ORGANIZATIONAL_UNIT_NAME, self._ou),
        ]
        subject = x509.Name(
            [x509.NameAttribute(x[0], x[1]) for x in attr_var_map if x[1]]
        )
        logging.info('Resulting subject: %s', subject.rfc4514_string())
        return subject

    def _make_alt_names(self):
        logging.info('Building alt names')
        alt_names = []
        if self._alt:
            for a in self._alt:
                alt_names.append(x509.DNSName(a))
        return alt_names

    @abstractmethod
    def generate(self):
        raise NotImplementedError

    def get_key_content(self):
        return self._key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.NoEncryption(),
        )

    def dump_key(self, file):
        logging.info('Writing out private key')
        content = self.get_key_content()
        file.write(content)

    @abstractmethod
    def get_object_content(self):
        raise NotImplementedError

    def dump_object(self, file):
        logging.info('Writing out object')
        content = self.get_object_content()
        file.write(content)


class RequestGenerator(X509Creator):
    def __init__(self, *args, **kwargs):
        self._csr = None  # type: CertificateSigningRequest
        super(RequestGenerator, self).__init__(*args, **kwargs)

    def generate(self):
        self._csr = x509.CertificateSigningRequestBuilder().subject_name(
            self._make_subject()
        ).add_extension(
            x509.SubjectAlternativeName(self._make_alt_names()),
            critical=False
        ).sign(self._key, hashes.SHA256())

    def get_object_content(self):
        return self._csr.public_bytes(serialization.Encoding.PEM)


class CertificateGenerator(X509Creator):
    # def __init__(self, *args, **kwargs):
    #     super(CertificateGenerator, self).__init__(*args, **kwargs)
    #     self._x509_extensions = ([
    #         crypto.X509Extension(b"keyUsage", False, b"Digital Signature,Non Repudiation,Key Encipherment"),
    #         crypto.X509Extension(b"basicConstraints", False, b"CA:FALSE"),
    #     ])

    def __init__(self, *args, **kwargs):
        self._cert = None  # type: Certificate
        super(CertificateGenerator, self).__init__(*args, **kwargs)

    def generate(self):
        if self._key is None:
            self._generate_key()
        subject = issuer = self._make_subject()
        self._cert = x509.CertificateBuilder().subject_name(
            subject
        ).issuer_name(
            issuer
        ).public_key(
            self._key.public_key()
        ).serial_number(
            x509.random_serial_number()
        ).not_valid_before(
            datetime.datetime.utcnow()
        ).not_valid_after(
            datetime.datetime.utcnow() + datetime.timedelta(days=10 * 365)
        ).add_extension(
            x509.SubjectAlternativeName(self._make_alt_names()),
            critical=False
        ).sign(self._key, hashes.SHA256())

    def get_object_content(self):
        return self._cert.public_bytes(serialization.Encoding.PEM)


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

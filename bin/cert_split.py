#!/bin/env python3

import click

@click.command()
@click.option('--cert', type=click.File('r'), default='-')
def cmd(cert):
    result = "-----BEGIN CERTIFICATE-----"
    chunk = cert.read(64)
    while chunk:
        result += "\n"
        result += chunk
        chunk = cert.read(64)
    result += "-----END CERTIFICATE-----\n"
    print(result)

if __name__ == '__main__':
    cmd()


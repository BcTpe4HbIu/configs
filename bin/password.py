#!/bin/env python3
import string
from random import choice
import argparse
import crypt

def main():
    parser = argparse.ArgumentParser(description='Generate password')
    parser.add_argument('-l','--length', type=int, default=8, help='password length')
    parser.add_argument('-p','--password', type=str, help='password')

    args = parser.parse_args()

    alphabet = string.ascii_letters + string.digits
    password = ''.join(choice(alphabet) for i in range(args.length))
    if args.password:
        password = args.password

    print("Password:",password)
    print("sha512:", crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512)))



if __name__ == '__main__':
    main()

#!/bin/env python3
import string
from random import choice
import argparse
import crypt

def main():
    parser = argparse.ArgumentParser(description='Generate password')
    parser.add_argument('-l','--length', type=int, default=8, help='password length')
    parser.add_argument('--linux', action='store_true', help='output linux hash')

    args = parser.parse_args()

    alphabet = string.ascii_letters + string.digits
    password = ''.join(choice(alphabet) for i in range(args.length))

    print("Password:",password)
    if args.linux:
        print(crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512)))



if __name__ == '__main__':
    main()

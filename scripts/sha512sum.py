#!/usr/bin/env python

from argparse import ArgumentParser
from hashlib import sha512
from logging import basicConfig, DEBUG
from pathlib import Path
from sys import argv, exit


argparser = ArgumentParser(
    description="sha512sum replacement if coreutils isn't installed"
)
argparser.add_argument("-c", "--check", type=Path, required=True)

if __name__ == "__main__":
    basicConfig(level=DEBUG)
    args = argparser.parse_args()
    errors = 0
    with open(str(args.check.resolve()), "rt") as f:
        for line in f:
            expected_hash, filename = line.rstrip("\r\n").split("  ", 1)
            with open(str(Path(filename).resolve()), "rb") as f:
                actual_hash = sha512(f.read()).hexdigest()

            if expected_hash == actual_hash:
                print(filename + ": OK")
            else:
                errors += 1
                print(filename + ": FAILED")

    if errors:
        print("%s: WARNING: %s computed checksum did NOT match" % (argv[0], errors))
        exit(1)
    else:
        exit(0)

#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, DEBUG, getLogger
from pathlib import Path

from pyjson5 import decode, encode


argparser = ArgumentParser(description='Run JSON5 parser tests')
argparser.add_argument('input', type=Path)
argparser.add_argument('output', nargs='?', type=Path)

if __name__ == '__main__':
    basicConfig(level=DEBUG)
    logger = getLogger(__name__)

    args = argparser.parse_args()
    try:
        # open() does not work with Paths in Python 3.5
        with open(str(args.input.resolve()), 'rt') as f:
            data = f.read()
    except Exception:
        logger.error('Could not even read file: %s', args.input, exc_info=True)
        raise SystemExit(-1)

    try:
        obj = decode(data)
    except Exception:
        logger.error('Could not parse content: %s', args.input)
        raise SystemExit(1)

    try:
        data = encode(obj)
    except Exception:
        logger.error('Could open stringify content: %s', args.input, exc_info=True)
        raise SystemExit(2)

    if args.output is not None:
        try:
            # open() does not work with Paths in Python 3.5
            with open(str(args.output.resolve()), 'wt') as f:
                f.write(data)
        except Exception:
            logger.error('Could open output file: %s', args.output, exc_info=True)
            raise SystemExit(-1)

    raise SystemExit(0)


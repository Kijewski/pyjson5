#!/usr/bin/env python

from argparse import ArgumentParser
from collections.abc import Mapping, Sequence
from codecs import open as codecs_open
from itertools import zip_longest
from json import loads
from logging import basicConfig, DEBUG, getLogger
from math import isnan
from pathlib import Path

from pyjson5 import decode, encode


def eq_with_nans(left, right):
    if left == right:
        return True
    elif isnan(left):
        return isnan(right)
    elif isnan(right):
        return False

    if not isinstance(left, Sequence) or not isinstance(right, Sequence):
        return False
    elif len(left) != len(right):
        return False

    left_mapping = isinstance(left, Mapping)
    right_mapping = isinstance(right, Mapping)
    if left_mapping != right_mapping:
        return False

    sentinel = object()
    if left_mapping:
        for k, left_value in left.items():
            right_value = right.pop(k, sentinel)
            if not eq_with_nans(left_value, right_value):
                return False
        if right:
            # extraneous keys
            return False
    else:
        for l, r in zip_longest(left, right, fillvalue=sentinel):
            if not eq_with_nans(l, r):
                return False

    return True


argparser = ArgumentParser(description="Run JSON5 parser tests")
argparser.add_argument("input", type=Path)
argparser.add_argument("output", nargs="?", type=Path)

if __name__ == "__main__":
    basicConfig(level=DEBUG)
    logger = getLogger(__name__)

    args = argparser.parse_args()
    try:
        with codecs_open(args.input.resolve(), "r", "UTF-8") as f:
            data = f.read()
    except Exception:
        logger.error("Could not even read file: %s", args.input, exc_info=True)
        raise SystemExit(-1)

    try:
        obj = decode(data)
    except Exception:
        logger.error("Could not parse content: %s", args.input)
        raise SystemExit(1)

    try:
        json_obj = loads(data)
    except Exception:
        pass
    else:
        if not eq_with_nans(obj, json_obj):
            logger.error(
                "JSON and PyJSON5 did not read the same data: %s, %r != %r",
                args.input,
                obj,
                json_obj,
            )
            raise SystemExit(2)

    try:
        data = encode(obj)
    except Exception:
        logger.error("Could open stringify content: %s", args.input, exc_info=True)
        raise SystemExit(2)

    if args.output is not None:
        try:
            with codecs_open(args.output.resolve(), "w", "UTF-8") as f:
                f.write(data)
        except Exception:
            logger.error("Could open output file: %s", args.output, exc_info=True)
            raise SystemExit(-1)

    raise SystemExit(0)

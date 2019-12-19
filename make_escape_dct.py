#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, DEBUG
from pathlib import Path


def generate(f):
    unescaped = 0
    print('const EscapeDct::Items EscapeDct::items = {', file=f)
    for c in range(0x100):
        if c == ord('\\'):
            s = '\\\\'
        elif c == ord('\b'):
            s = '\\b'
        elif c == ord('\f'):
            s = '\\f'
        elif c == ord('\n'):
            s = '\\n'
        elif c == ord('\r'):
            s = '\\r'
        elif c == ord('\t'):
            s = '\\t'
        elif (c < 0x20) or (c >= 0x7f) or (chr(c) in '''"'&<>\\'''):
            s = f'\\u{c:04x}'
        else:
            s = f'{c:c}'
            if c < 128:
                unescaped |= 1 << c

        t = [str(len(s))] + [
            f"'{c}'" if c != '\\' else f"'\\\\'"
            for c in s
        ] + ['0'] * 6
        print('    {' + ', '.join(t[:8]) + '},', file=f)
    print('};', file=f)

    escaped = unescaped ^ ((1 << 128) - 1)
    print('const unsigned __int128 EscapeDct::is_escaped_array = (', file=f)
    print(f'    ((unsigned __int128) 0x{(escaped >> 64):016x} << 64) |', file=f)
    print(f'    ((unsigned __int128) 0x{(escaped & ((1 << 64) - 1)):016x})', file=f)
    print(');', file=f)


argparser = ArgumentParser(description='Generate src/_escape_dct.hpp')
argparser.add_argument('input', nargs='?', type=Path, default=Path('src/_escape_dct.hpp'))

if __name__ == '__main__':
    basicConfig(level=DEBUG)
    args = argparser.parse_args()
    with open(str(args.input.resolve()), 'wt') as out:
        generate(out)

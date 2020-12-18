#!/usr/bin/env python3

from argparse import ArgumentParser
from collections import defaultdict
from functools import reduce
from pathlib import Path
from re import match

from more_itertools import chunked


def main(input_file, output_file):
    Nothing = 0
    WhiteSpace = 1
    IdentifierStart = 2
    IdentifierPart = 3

    cat_indices = {
        'zs': WhiteSpace,

        'lc': IdentifierStart,
        'll': IdentifierStart,
        'lm': IdentifierStart,
        'lo': IdentifierStart,
        'lt': IdentifierStart,
        'lu': IdentifierStart,
        'nl': IdentifierStart,

        'mc': IdentifierPart,
        'mn': IdentifierPart,
        'pc': IdentifierPart,
        'nd': IdentifierPart,
    }

    planes = defaultdict(lambda: [0] * 0x10000)

    for input_line in input_file:
        m = match(r'^([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+([A-Z][a-z])', input_line)
        if not m:
            continue
        start, end, cat = m.groups()

        idx = cat_indices.get(cat.lower())
        if idx:
            end = int(end or start, 16)
            start = int(start, 16)
            for i in range(start, end + 1):
                planes[i // 0x10000][i % 0x10000] = idx

    # per: https://spec.json5.org/#white-space
    for i in (0x9, 0xa, 0xb, 0xc, 0xd, 0x20, 0xa0, 0x2028, 0x2028, 0x2029, 0xfeff):
        planes[0][i] = WhiteSpace

    # per: https://www.ecma-international.org/ecma-262/5.1/#sec-7.6
    for i in (ord('$'), ord('_'), ord('\\')):
        planes[0][i] = IdentifierStart

    # per: https://www.ecma-international.org/ecma-262/5.1/#sec-7.6
    for i in (0x200C, 0x200D):
        planes[0][i] = IdentifierPart

    print('#ifndef JSON5EncoderCpp_unicode_cat_of', file=output_file)
    print('#define JSON5EncoderCpp_unicode_cat_of', file=output_file)
    print(file=output_file)
    print('// GENERATED FILE', file=output_file)
    print('// All changes will be lost.', file=output_file)
    print(file=output_file)
    print('#include <cstdint>', file=output_file)
    print(file=output_file)
    print('namespace JSON5EncoderCpp {', file=output_file)
    print('inline namespace {', file=output_file)
    print(file=output_file)
    print('static unsigned unicode_cat_of(std::uint32_t codepoint) {', file=output_file)

    print('    static std::uint8_t plane_X[0x10000 / 4] = {0};', file=output_file)
    print(file=output_file)

    for plane_idx, plane_data in planes.items():
        print('    static std::uint8_t plane_' + str(plane_idx) + '[0x10000 / 4] = {', file=output_file)
        for chunk in chunked(plane_data, 4*16):
            print('        ', end='', file=output_file)
            for value in chunked(chunk, 4):
                value = reduce(lambda a, i: ((a << 2) | i), reversed(value), 0)
                print('0x{:02x}u'.format(value), end=', ', file=output_file)
            print(file=output_file)
        print('    };', file=output_file)
        print(file=output_file)

    print('    static std::uint8_t *planes[17] = {', end='', file=output_file)
    for plane_idx in range(0, 17):
        if plane_idx % 8 == 0:
            print('\n        ', end='', file=output_file)
        if plane_idx in planes:
            print('plane_' + str(plane_idx) + ', ', end='', file=output_file)
        else:
            print('plane_X, ', end='', file=output_file)
    print(file=output_file)
    print('    };', file=output_file)
    print(file=output_file)

    print('    std::uint16_t plane_idx = std::uint16_t(codepoint / 0x10000);', file=output_file)
    print('    if (JSON5EncoderCpp_expect(plane_idx > 16, false)) return 1;', file=output_file)
    print('    std::uint16_t datum_idx = std::uint16_t(codepoint & 0xffff);', file=output_file)
    print('    const std::uint8_t *plane = planes[plane_idx];', file=output_file)
    print('    return (plane[datum_idx / 4] >> (2 * (datum_idx % 4))) % 4;', file=output_file)
    print('}', file=output_file)
    print(file=output_file)
    print('}', file=output_file)
    print('}', file=output_file)
    print(file=output_file)
    print('#endif', file=output_file)


argparser = ArgumentParser(description='Generate Unicode Category Matcher(s)')
argparser.add_argument('input', nargs='?', type=Path, default=Path('/dev/stdin'))
argparser.add_argument('output', nargs='?', type=Path, default=Path('/dev/stdout'))

if __name__ == '__main__':
    args = argparser.parse_args()
    with open(str(args.input.resolve()), 'rt') as input_file, \
         open(str(args.output.resolve()), 'wt') as output_file:
        raise SystemExit(main(input_file, output_file))

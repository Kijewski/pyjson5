#!/usr/bin/env python

from argparse import ArgumentParser
from collections import defaultdict, OrderedDict
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
        "zs": WhiteSpace,
        "lc": IdentifierStart,
        "ll": IdentifierStart,
        "lm": IdentifierStart,
        "lo": IdentifierStart,
        "lt": IdentifierStart,
        "lu": IdentifierStart,
        "nl": IdentifierStart,
        "mc": IdentifierPart,
        "mn": IdentifierPart,
        "pc": IdentifierPart,
        "nd": IdentifierPart,
    }

    planes = defaultdict(lambda: [0] * 0x100)

    for input_line in input_file:
        m = match(r"^([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s+;\s+([A-Z][a-z])", input_line)
        if not m:
            continue
        start, end, cat = m.groups()

        idx = cat_indices.get(cat.lower())
        if idx:
            end = int(end or start, 16)
            start = int(start, 16)
            for i in range(start, end + 1):
                planes[i // 0x100][i % 0x100] = idx

    # per: https://spec.json5.org/#white-space
    for i in (0x9, 0xA, 0xB, 0xC, 0xD, 0x20, 0xA0, 0x2028, 0x2028, 0x2029, 0xFEFF):
        planes[i // 0x100][i % 0x100] = WhiteSpace

    # per: https://www.ecma-international.org/ecma-262/5.1/#sec-7.6
    for i in (ord("$"), ord("_"), ord("\\")):
        planes[i // 0x100][i % 0x100] = IdentifierStart

    # per: https://www.ecma-international.org/ecma-262/5.1/#sec-7.6
    for i in (0x200C, 0x200D):
        planes[i // 0x100][i % 0x100] = IdentifierPart

    print("#ifndef JSON5EncoderCpp_unicode_cat_of", file=output_file)
    print("#define JSON5EncoderCpp_unicode_cat_of", file=output_file)
    print(file=output_file)
    print("// GENERATED FILE", file=output_file)
    print("// All changes will be lost.", file=output_file)
    print(file=output_file)
    print("#include <cstdint>", file=output_file)
    print(file=output_file)
    print("namespace JSON5EncoderCpp {", file=output_file)
    print("inline namespace {", file=output_file)
    print(file=output_file)
    print("static unsigned unicode_cat_of(std::uint32_t codepoint) {", file=output_file)

    demiplane_to_idx = OrderedDict()  # demiplane_idx → data_idx
    data_to_idx = [None] * 17 * 0x100  # demiplane data → data_idx
    print("    // A 'demiplane' is a 1/256th of a Unicode plane.", file=output_file)
    print("    // This way a 'demiplane' fits nicely into a cache line.", file=output_file)
    print("    alignas(64) static const std::uint8_t demiplane_data[][0x100 / 4] = {", file=output_file)
    for i in range(17 * 0x100):
        plane_data = ""
        plane = planes[i]
        while plane and plane[-1] == 0:
            plane.pop()

        for chunk in chunked(plane, 4 * 16):
            plane_data += "            "
            for value in chunked(chunk, 4):
                value = reduce(lambda a, i: ((a << 2) | i), reversed(value), 0)
                plane_data += "0x{:02x}u, ".format(value)
            plane_data = plane_data[:-1] + "\n"

        produced_idx = demiplane_to_idx.get(plane_data)
        if produced_idx is None:
            produced_idx = len(demiplane_to_idx)
            print("        {{  // {} -> 0x{:02x}u".format(i, len(demiplane_to_idx)), file=output_file)
            print(plane_data, file=output_file, end="")
            print("        },", file=output_file)
            demiplane_to_idx[plane_data] = produced_idx

        data_to_idx[i] = produced_idx
    print("    };", end="", file=output_file)
    print(file=output_file)

    print("    alignas(64) static const std::uint8_t demiplane_indices[17 * 0x100] = {", end="", file=output_file)
    for i in range(17 * 0x100):
        if i % 16 == 0:
            print("\n       ", end="", file=output_file)
        print(" 0x{:02x}u,".format(data_to_idx[i]), end="", file=output_file)
    print(file=output_file)
    print("    };", file=output_file)
    print(file=output_file)

    print(
        "    std::uint32_t demiplane_idx = codepoint / 0x100;",
        file=output_file,
    )
    print(
        "    if (JSON5EncoderCpp_expect(demiplane_idx >= 17 * 0x100, false)) return 1;",
        file=output_file,
    )
    print(
        "    std::uint32_t datum_idx = codepoint & (0x100 - 1);",
        file=output_file,
    )
    print(
        "    const std::uint8_t *demiplane = demiplane_data[demiplane_indices[demiplane_idx]];",
        file=output_file,
    )
    print(
        "    return (demiplane[datum_idx / 4] >> (2 * (datum_idx % 4))) % 4;",
        file=output_file,
    )
    print("}", file=output_file)
    print(file=output_file)
    print("}", file=output_file)
    print("}", file=output_file)
    print(file=output_file)
    print("#endif", file=output_file)


argparser = ArgumentParser(description="Generate Unicode Category Matcher(s)")
argparser.add_argument("input", nargs="?", type=Path, default=Path("/dev/stdin"))
argparser.add_argument("output", nargs="?", type=Path, default=Path("/dev/stdout"))

if __name__ == "__main__":
    args = argparser.parse_args()
    with open(str(args.input.resolve()), "rt") as input_file, open(
        str(args.output.resolve()), "wt"
    ) as output_file:
        raise SystemExit(main(input_file, output_file))

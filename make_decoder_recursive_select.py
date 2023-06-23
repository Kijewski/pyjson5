#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, DEBUG
from pathlib import Path

from more_itertools import chunked


def generate(out):
    lst = ["DRS_fail"] * 128
    lst[ord("n")] = "DRS_null"
    lst[ord("t")] = "DRS_true"
    lst[ord("f")] = "DRS_false"
    lst[ord("I")] = "DRS_inf"
    lst[ord("N")] = "DRS_nan"
    lst[ord('"')] = "DRS_string"
    lst[ord("'")] = "DRS_string"
    lst[ord("{")] = "DRS_recursive"
    lst[ord("[")] = "DRS_recursive"
    for c in "+-.0123456789":
        lst[ord(c)] = "DRS_number"

    print("#ifndef JSON5EncoderCpp_decoder_recursive_select", file=out)
    print("#define JSON5EncoderCpp_decoder_recursive_select", file=out)
    print(file=out)
    print("// GENERATED FILE", file=out)
    print("// All changes will be lost.", file=out)
    print(file=out)
    print("#include <cstdint>", file=out)
    print(file=out)
    print("namespace JSON5EncoderCpp {", file=out)
    print("inline namespace {", file=out)
    print(file=out)
    print("enum DrsKind : std::uint8_t {", file=out)
    print(
        "    DRS_fail, DRS_null, DRS_true, DRS_false, DRS_inf, DRS_nan, DRS_string, DRS_number, DRS_recursive",
        file=out,
    )
    print("};", file=out)
    print(file=out)
    print("static const DrsKind drs_lookup[128] = {", file=out)
    for chunk in chunked(lst, 8):
        print("   ", end="", file=out)
        for t in chunk:
            print(" ", t, ",", sep="", end="", file=out)
        print(file=out)
    print("};", file=out)
    print(file=out)
    print("}  // anonymous inline namespace", sep="", file=out)
    print("}  // namespace JSON5EncoderCpp", sep="", file=out)
    print(file=out)
    print("#endif", sep="", file=out)


argparser = ArgumentParser(description="Generate src/_decoder_recursive_select.hpp")
argparser.add_argument(
    "input", nargs="?", type=Path, default=Path("src/_decoder_recursive_select.hpp")
)

if __name__ == "__main__":
    basicConfig(level=DEBUG)
    args = argparser.parse_args()
    with open(str(args.input.resolve()), "wt") as out:
        generate(out)

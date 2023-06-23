#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, DEBUG
from pathlib import Path


def generate(f):
    unescaped = 0
    print("const EscapeDct::Items EscapeDct::items = {", file=f)
    for c in range(0x100):
        if c == ord("\\"):
            s = "\\\\"
        elif c == ord("\b"):
            s = "\\b"
        elif c == ord("\f"):
            s = "\\f"
        elif c == ord("\n"):
            s = "\\n"
        elif c == ord("\r"):
            s = "\\r"
        elif c == ord("\t"):
            s = "\\t"
        elif c == ord('"'):
            s = '\\"'
        elif (c < 0x20) or (c >= 0x7F) or (chr(c) in "'&<>\\"):
            s = f"\\u{c:04x}"
        else:
            s = f"{c:c}"
            if c < 128:
                unescaped |= 1 << c

        t = (
            [str(len(s))]
            + [f"'{c}'" if c != "\\" else f"'\\\\'" for c in s]
            + ["0"] * 6
        )
        l = ", ".join(t[:8])
        print(f"   {{ {l:35s} }},  /* 0x{c:02x} {chr(c)!r} */", file=f)
    print("};", file=f)

    escaped = unescaped ^ ((1 << 128) - 1)
    print(
        f"const std::uint64_t EscapeDct::is_escaped_lo = UINT64_C(0x{(escaped & ((1 << 64) - 1)):016x});",
        file=f,
    )
    print(
        f"const std::uint64_t EscapeDct::is_escaped_hi = UINT64_C(0x{(escaped >> 64):016x});",
        file=f,
    )


argparser = ArgumentParser(description="Generate src/_escape_dct.hpp")
argparser.add_argument(
    "input", nargs="?", type=Path, default=Path("src/_escape_dct.hpp")
)

if __name__ == "__main__":
    basicConfig(level=DEBUG)
    args = argparser.parse_args()
    with open(str(args.input.resolve()), "wt") as out:
        generate(out)

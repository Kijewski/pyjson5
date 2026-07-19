#!/usr/bin/env python

# Value-level conformance checks for the JSON5 number and string-escape
# grammar. The expected results follow the JSON5 spec and match the reference
# implementation (json5 npm 2.2.3), stdlib json and dpranke's json5 where those
# apply. run-tests.py only checks accept/reject; this pins the parsed values.

from math import inf, isnan, nan

from pyjson5 import Json5Exception, decode

THROW = object()

CASES = [
    # JSON5 has no numeric separators; '_' is not part of any number
    ("1000", 1000), ("1_000", THROW), ("1__0", THROW), ("1_", THROW),
    ("10_", THROW), ("1.5_", THROW), ("1e3_", THROW), ("-1_0", THROW),
    ("0x1_0", THROW), ("0x_F", THROW), ("0x10_", THROW), ("1_e3", THROW),
    # a leading '.' needs a fractional digit before any exponent or the end
    (".5", 0.5), (".0", 0.0), ("-.5", -0.5), ("+.25", 0.25),
    (".e5", THROW), (".e+5", THROW), (".", THROW),
    # at most one '.', never after the exponent, no doubled/trailing dots
    ("5.", 5.0), ("0.", 0.0), ("1.e5", 100000.0), ("0.e1", 0.0),
    ("10.e-2", 0.1), ("5.8.", THROW), (".5.", THROW), ("2e400.", THROW),
    # a sign is only valid at the start (consumed) or right after 'e'/'E'
    ("+7", 7), ("++7", THROW), ("+-.4", THROW), ("1e+5", 100000.0),
    ("1e-5", 1e-05),
    # the exponent must have at least one digit
    ("0e", THROW), ("0e+", THROW), ("1e", THROW), ("1e+", THROW), ("0e5", 0.0),
    # overflow follows ECMAScript ToNumber (-> +/-Infinity); underflow -> 0
    ("1e999", inf), ("-1e999", -inf), ("1e400", inf), ("9e999", inf),
    ("1e308", 1e308), ("1e-999", 0.0),
    # hexadecimal and leading-zero integers
    ("0xFF", 255), ("0x10", 16), ("-0xff", -255), ("0x", THROW),
    ("01", THROW), ("007", THROW), ("00", THROW),
    # \0 is NUL only when not followed by a decimal digit (no legacy octal)
    (r'"\0"', "\x00"), (r'"\0a"', "\x00a"), (r'"\09"', THROW),
    (r'"\07"', THROW), (r'"\00"', THROW), (r"'\09'", THROW),
    # unrelated escapes and literals stay valid
    (r'"\x41"', "A"), (r'"A"', "A"), ("Infinity", inf), ("NaN", nan),
]


def check():
    bad = 0
    for src, expected in CASES:
        try:
            got = decode(src)
            threw = False
        except Json5Exception:
            got = None
            threw = True

        if expected is THROW:
            ok = threw
        elif threw:
            ok = False
        elif isinstance(expected, float) and isnan(expected):
            ok = isinstance(got, float) and isnan(got)
        else:
            ok = type(got) is type(expected) and got == expected

        if not ok:
            bad += 1
            outcome = "was rejected" if threw else f"gave {got!r}"
            want = "to be rejected" if expected is THROW else repr(expected)
            print(f"BAD {src!r}: {outcome}, expected {want}")

    return bad


if __name__ == "__main__":
    bad = check()
    print(f"\n{len(CASES) - bad} of {len(CASES)} conformance cases passed")
    raise SystemExit(1 if bad else 0)

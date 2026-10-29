#!/usr/bin/env python
"""
Test that encoding finite floats round-trips exactly, including zeros and subnormals.

Exits 0 on success, 1 on failure.
"""

from __future__ import annotations

import json
import struct
import sys
from typing import Any

import pyjson5


def _bits(value: float) -> bytes:
    return struct.pack("<d", value)


VALUES = [
    0.0,
    -0.0,
    5e-324,  # smallest subnormal
    -5e-324,
    1e-310,
    2.225073858507201e-308,  # largest subnormal
    2.2250738585072014e-308,  # smallest normal
    0.1,
    -1.5,
    1e16,
    1e22,
    1.7976931348623157e308,
]


def main() -> int:
    failures = []

    def check(name: str, ok: bool, detail: Any = "") -> None:
        print(f"{'OK  ' if ok else 'FAIL'} {name}{'' if ok else f': {detail!r}'}")
        if not ok:
            failures.append(name)

    for value in VALUES:
        encoded = pyjson5.encode(value)
        decoded = pyjson5.decode(encoded)
        check(
            f"encode({value!r}) == {encoded!r} round-trips",
            isinstance(decoded, float) and _bits(decoded) == _bits(value),
            decoded,
        )
        from_json = json.loads(encoded)
        check(
            f"json.loads(encode({value!r})) round-trips",
            _bits(float(from_json)) == _bits(value),
            from_json,
        )

    encoded = pyjson5.encode([0.0, -0.0, 5e-324])
    decoded = pyjson5.decode(encoded)
    check(
        "floats inside containers round-trip",
        [_bits(v) for v in decoded] == [_bits(v) for v in (0.0, -0.0, 5e-324)],
        encoded,
    )

    print()
    print(f"{len(failures)} failure(s)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

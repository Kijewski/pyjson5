#!/usr/bin/env python
"""
Test decode_io() and load() with text, binary and non-seekable streams.

Exits 0 on success, 1 on failure.
"""

from __future__ import annotations

import io
import os
import sys
import tempfile
from typing import Any, Callable

import pyjson5


DOC = "['Héllo', /* TODO 😀 */]\n'Wörld   中文' // FIXME\n[1, 'ß']\n"
VALUES = [["Héllo"], "Wörld   中文", [1, "ß"]]

INVALID_UTF8 = {
    "stray 0xFF": b'["ok", "a\xffb"]',
    "truncated at end of stream": b'["ok", "a\xc3',
    "truncated before quote": b'["ok", "a\xe4\xb8"]',
    "bad continuation byte": b'["ok", "a\xe2\x28\xa1"]',
    "overlong encoding": b'["ok", "a\xc0\xafb"]',
    "encoded surrogate": b'["ok", "a\xed\xa0\x80"]',
}


class NonSeekableRaw(io.RawIOBase):
    """Unbuffered, non-seekable stream returning at most one byte per read, like a slow pipe."""

    def __init__(self, data: bytes) -> None:
        self._data = data
        self._pos = 0

    def readable(self) -> bool:
        return True

    def readinto(self, b: Any) -> int:
        if self._pos >= len(self._data) or not len(b):
            return 0
        b[0] = self._data[self._pos]
        self._pos += 1
        return 1


def _streams(data: str) -> dict[str, Callable[[], io.IOBase]]:
    raw = data.encode("UTF-8")
    return {
        "StringIO": lambda: io.StringIO(data),
        "BytesIO": lambda: io.BytesIO(raw),
        "BufferedReader": lambda: io.BufferedReader(io.BytesIO(raw)),
        "non-seekable raw stream": lambda: NonSeekableRaw(raw),
        "buffered non-seekable stream": lambda: io.BufferedReader(NonSeekableRaw(raw)),
    }


def main() -> int:
    failures = []

    def check(name: str, ok: bool, detail: Any = "") -> None:
        print(f"{'OK  ' if ok else 'FAIL'} {name}{'' if ok else f': {detail!r}'}")
        if not ok:
            failures.append(name)

    for kind, make in _streams(DOC).items():
        fp = make()
        got = [pyjson5.decode_io(fp) for _ in VALUES]
        check(f"successive decode_io() on {kind}", got == VALUES and not fp.closed, got)

    with tempfile.TemporaryDirectory() as tmp:
        path = os.path.join(tmp, "doc.json5")
        with open(path, "wb") as fp:
            fp.write(DOC.encode("UTF-8"))
        for mode in ("r", "rb"):
            with open(path, mode, **({"encoding": "UTF-8"} if mode == "r" else {})) as fp:
                got = [pyjson5.decode_io(fp) for _ in VALUES]
            check(f"successive decode_io() on file opened with {mode!r}", got == VALUES, got)

        with open(path, "wb") as fp:
            fp.write("{'clé': ['😀', \"中文\"]}".encode("UTF-8"))
        with open(path, "rb") as fp:
            got = pyjson5.load(fp)
        check("load() on binary file", got == {"clé": ["😀", "中文"]}, got)

    for name, data in INVALID_UTF8.items():
        for func in (lambda fp: pyjson5.decode_io(fp, None, False), pyjson5.load):
            try:
                got = func(io.BytesIO(data))
            except pyjson5.Json5DecoderException:
                ok = True
            except Exception as ex:  # noqa: BLE001
                ok, got = False, ex
            else:
                ok = False
            check(f"invalid UTF-8 is rejected ({name})", ok, got)

    print()
    print(f"{len(failures)} failure(s)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

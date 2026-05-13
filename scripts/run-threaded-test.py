#!/usr/bin/env python
"""
Stress test pyjson5 from many concurrent OS threads.

Designed primarily to exercise the free-threaded CPython build (PEP 703).
On a GIL build it still runs as a soak test for re-entrancy / refcount safety,
just without true parallelism.

Exits 0 on success, 1 on result mismatch, 2 on exception.
"""

from __future__ import annotations

import io
import os
import random
import sys
import threading
import time
from argparse import ArgumentParser
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Any

import pyjson5


def _make_payload(rng: random.Random, depth: int) -> Any:
    """Random nested data structure that round-trips through JSON5."""
    if depth <= 0:
        choice = rng.randint(0, 5)
        if choice == 0:
            return None
        if choice == 1:
            return rng.choice((True, False))
        if choice == 2:
            return rng.randint(-(2**40), 2**40)
        if choice == 3:
            # Avoid NaN/Inf here so equality checks work cleanly.
            return rng.uniform(-1e9, 1e9)
        if choice == 4:
            # Mix of ASCII, escape-needing, and non-ASCII codepoints.
            return "".join(
                chr(rng.choice((0x20, 0x22, 0x5C, 0x7F, 0xE9, 0x2603, 0x1F600)))
                for _ in range(rng.randint(0, 12))
            )
        return rng.choice(("hello", "wörld", "snow☃man", "", "quote\"and\\back"))

    width = rng.randint(0, 5)
    if rng.random() < 0.5:
        return [_make_payload(rng, depth - 1) for _ in range(width)]
    return {f"k{i}": _make_payload(rng, depth - 1) for i in range(width)}


def _worker(worker_id: int, iterations: int, seed: int, barrier: threading.Barrier) -> tuple[int, int]:
    """Round-trip random payloads through encode/decode. Returns (worker_id, ok_count)."""
    rng = random.Random(seed)
    # All workers start at the same moment so contention is maximised.
    barrier.wait()
    ok = 0
    for _ in range(iterations):
        payload = _make_payload(rng, depth=rng.randint(0, 4))

        encoded = pyjson5.encode(payload)
        decoded = pyjson5.decode(encoded)
        if decoded != payload:
            raise AssertionError(
                f"worker {worker_id}: round-trip mismatch:\n"
                f"  payload={payload!r}\n  encoded={encoded!r}\n  decoded={decoded!r}"
            )

        # encode_bytes path
        encoded_b = pyjson5.encode_bytes(payload)
        decoded_b = pyjson5.decode_utf8(encoded_b)
        if decoded_b != payload:
            raise AssertionError(
                f"worker {worker_id}: bytes round-trip mismatch:\n"
                f"  payload={payload!r}\n  encoded_b={encoded_b!r}\n  decoded_b={decoded_b!r}"
            )

        # encode_io / decode_io path
        sio = io.StringIO()
        pyjson5.encode_io(payload, sio, supply_bytes=False)
        sio.seek(0)
        decoded_io = pyjson5.decode_io(sio)
        if decoded_io != payload:
            raise AssertionError(
                f"worker {worker_id}: io round-trip mismatch:\n"
                f"  payload={payload!r}\n  encoded_io={sio.getvalue()!r}\n  decoded_io={decoded_io!r}"
            )

        ok += 1
    return worker_id, ok


def _shared_object_worker(shared: Any, iterations: int, barrier: threading.Barrier) -> int:
    """Encode the *same* nested object from many threads to exercise concurrent reads."""
    barrier.wait()
    expected = pyjson5.encode(shared)
    for _ in range(iterations):
        if pyjson5.encode(shared) != expected:
            raise AssertionError("shared-object encode produced inconsistent output")
        # Also re-decode and compare.
        if pyjson5.decode(expected) != shared:
            raise AssertionError("shared-object decode produced inconsistent output")
    return iterations


def main() -> int:
    parser = ArgumentParser(description=__doc__)
    parser.add_argument(
        "--threads",
        type=int,
        default=max(4, (os.cpu_count() or 4) * 2),
        help="number of worker threads (default: 2 * CPU count, min 4)",
    )
    parser.add_argument(
        "--iterations",
        type=int,
        default=2000,
        help="round-trip iterations per worker (default: 2000)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=0xDEADBEEF,
        help="base RNG seed (default: 0xDEADBEEF)",
    )
    args = parser.parse_args()

    print(f"Python: {sys.version}")
    gil_disabled = getattr(sys, "_is_gil_enabled", lambda: True)() is False
    print(f"GIL disabled: {gil_disabled}")
    print(f"pyjson5: {pyjson5.__version__}")
    print(f"Workers: {args.threads}  Iterations/worker: {args.iterations}")

    barrier = threading.Barrier(args.threads)
    start = time.perf_counter()
    try:
        # Round 1: each worker has its own RNG and builds independent payloads.
        with ThreadPoolExecutor(max_workers=args.threads) as pool:
            futures = [
                pool.submit(_worker, i, args.iterations, args.seed + i, barrier)
                for i in range(args.threads)
            ]
            total_ok = 0
            for fut in as_completed(futures):
                _wid, ok = fut.result()
                total_ok += ok

        # Round 2: all workers hammer the SAME shared object concurrently.
        shared = {
            "list": list(range(50)),
            "nested": {"a": [1, 2, {"b": "héllo ☃"}], "c": None, "d": True},
            "string": "the quick brown fox jumps over the lazy dog " * 10,
        }
        barrier2 = threading.Barrier(args.threads)
        with ThreadPoolExecutor(max_workers=args.threads) as pool:
            futures = [
                pool.submit(_shared_object_worker, shared, args.iterations // 2, barrier2)
                for _ in range(args.threads)
            ]
            for fut in as_completed(futures):
                fut.result()
    except AssertionError as exc:
        print(f"\nFAIL: {exc}", file=sys.stderr)
        return 1
    except Exception:
        import traceback
        traceback.print_exc()
        return 2

    elapsed = time.perf_counter() - start
    print(
        f"\nOK: {total_ok} round-trips across {args.threads} threads in {elapsed:.2f}s "
        f"({total_ok / elapsed:.0f} ops/s)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

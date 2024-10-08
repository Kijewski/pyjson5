#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, INFO, getLogger
from os import chdir, name
from pathlib import Path
from subprocess import Popen
from sys import executable


argparser = ArgumentParser(description="Run JSON5 parser tests")
argparser.add_argument(
    "tests",
    nargs="?",
    type=Path,
    default=Path("third-party/JSONTestSuite/test_parsing"),
)

suffix_implies_success = {
    "json": True,
    "json5": True,
    "txt": False,
}

if __name__ == "__main__":
    basicConfig(level=INFO)
    logger = getLogger(__name__)
    chdir(Path(__file__).absolute().parent.parent)

    good = bad = errors = severe = 0

    try:
        from colorama import init, Fore

        init()
    except Exception:
        code_severe = "SEVERE"
        code_good = "GOOD"
        code_bad = "BAD"
        code_ignored = "IGNORED"
        reset = ""
    else:
        if name != "nt":
            code_severe = Fore.RED + "😱"
            code_good = Fore.CYAN + "😄"
            code_bad = Fore.YELLOW + "😠"
            code_ignored = Fore.BLUE + "🙅"
        else:
            code_severe = Fore.RED + "SEVERE"
            code_good = Fore.CYAN + "GOOD"
            code_bad = Fore.YELLOW + "BAD"
            code_ignored = Fore.BLUE + "IGNORED"
        reset = Fore.RESET

    script = str(Path(__file__).absolute().parent / "transcode-to-json.py")

    args = argparser.parse_args()
    index = 0
    for path in sorted(args.tests.glob("?_?*.json")):
        category, name = path.stem.split("_", 1)
        if category not in "yni":
            continue

        if category in "ni":
            # ignore anything but tests that are expected to pass for now
            continue

        try:
            # ignore any UTF-8 errors
            with open(str(path.resolve()), "rt") as f:
                f.read()
        except Exception:
            continue

        index += 1
        try:
            p = Popen((executable, script, str(path)))
            outcome = p.wait(5)
        except Exception:
            logger.error("Error while testing: %s", path, exc_info=True)
            errors += 1
            continue

        if outcome not in (0, 1):
            code = code_severe
            severe += 1
        elif category == "y":
            if outcome == 0:
                code = code_good
                good += 1
            else:
                code = code_bad
                bad += 1
        else:
            code = code_ignored

        print(
            "#",
            index,
            " ",
            code,
            " | " "Category <",
            category,
            "> | " "Test <",
            name,
            "> | " "Actual <",
            "pass" if outcome == 0 else "FAIL",
            ">",
            reset,
            sep="",
        )

    is_severe = severe > 0
    is_good = bad == 0
    code = code_severe if is_severe else code_good if is_good else code_bad
    print()
    print(
        code,
        " | ",
        good,
        " correct outcomes | ",
        bad,
        " wrong outcomes | ",
        severe,
        " severe errors",
        reset,
        sep="",
    )
    raise SystemExit(2 if is_severe else 0 if is_good else 1)

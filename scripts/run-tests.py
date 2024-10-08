#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, INFO, getLogger
from os import chdir, name
from pathlib import Path
from subprocess import Popen
from sys import executable


argparser = ArgumentParser(description="Run JSON5 parser tests")
argparser.add_argument(
    "tests", nargs="?", type=Path, default=Path("third-party/json5-tests")
)

suffix_implies_success = {
    ".json": True,
    ".json5": True,
    ".txt": False,
}

if __name__ == "__main__":
    basicConfig(level=INFO)
    logger = getLogger(__name__)
    chdir(Path(__file__).absolute().parent.parent)

    try:
        from colorama import init, Fore

        init()
    except Exception:
        code_severe = "SEVERE"
        code_good = "GOOD"
        code_bad = "BAD"
        reset = ""
    else:
        if name != "nt":
            code_severe = Fore.RED + "😱"
            code_good = Fore.CYAN + "😄"
            code_bad = Fore.YELLOW + "😠"
        else:
            code_severe = Fore.RED + "SEVERE"
            code_good = Fore.CYAN + "GOOD"
            code_bad = Fore.YELLOW + "BAD"
        reset = Fore.RESET

    good = 0
    bad = 0
    severe = 0

    script = str(Path(__file__).absolute().parent / "transcode-to-json.py")

    args = argparser.parse_args()
    index = 0
    for path in sorted(args.tests.glob("*/*.*")):
        kind = path.suffix.split(".")[-1]
        expect_success = suffix_implies_success.get(path.suffix)
        if expect_success is None:
            continue

        index += 1
        category = path.parent.name
        name = path.stem
        try:
            p = Popen((executable, script, str(path)))
            outcome = p.wait(5)
        except Exception:
            logger.error("Error while testing: %s", path, exc_info=True)
            severe += 1
            continue

        is_success = outcome == 0
        is_failure = outcome == 1
        is_severe = outcome not in (0, 1)
        is_good = is_success if expect_success else is_failure
        code = code_severe if is_severe else code_good if is_good else code_bad
        print(
            "#",
            index,
            " ",
            code,
            " " "Category <",
            category,
            "> | " "Test <",
            name,
            "> | " "Data <",
            kind,
            "> | " "Expected <",
            "pass" if expect_success else "FAIL",
            "> | " "Actual <",
            "pass" if is_success else "FAIL",
            ">",
            reset,
            sep="",
        )
        if is_severe:
            severe += 1
        elif is_good:
            good += 1
        else:
            bad += 1

    is_severe = severe > 0
    is_good = bad == 0
    code = code_severe if is_severe else code_good if is_good else code_bad
    print()
    print(
        code,
        " ",
        good,
        " × correct outcome | ",
        bad,
        " × wrong outcome | ",
        severe,
        " × severe errors",
        reset,
        sep="",
    )
    raise SystemExit(2 if is_severe else 0 if is_good else 1)

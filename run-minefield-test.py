#!/usr/bin/env python

from argparse import ArgumentParser
from logging import basicConfig, INFO, getLogger
from pathlib import Path
from subprocess import Popen

from colorama import init, Fore
from pyjson5 import decode_io


argparser = ArgumentParser(description='Run JSON5 parser tests')
argparser.add_argument('tests', nargs='?', type=Path, default=Path('third-party/JSONTestSuite/test_parsing'))

suffix_implies_success = {
    'json': True,
    'json5': True,
    'txt': False,
}

if __name__ == '__main__':
    basicConfig(level=INFO)
    logger = getLogger(__name__)

    init()

    good = bad = severe = 0

    args = argparser.parse_args()
    index = 0
    for path in sorted(args.tests.glob('?_?*.json')):
        category, name = path.stem.split('_', 1)
        if category not in 'yni':
            continue

        if category in 'ni':
            # ignore anything but tests that are expected to pass for now
            continue

        try:
            # ignore any UTF-8 errors
            with open(str(path.resolve()), 'rt') as f:
                f.read()
        except Exception:
            continue

        index += 1
        try:
            p = Popen(('/usr/bin/env', 'python', 'transcode-to-json.py', str(path)))
            outcome = p.wait(5)
        except Exception:
            logger.error('Error while testing: %s', path, exc_info=True)
            errors += 1
            continue

        if outcome not in (0, 1):
            code = Fore.RED + '😱'
            severe += 1
        elif category == 'y':
            if outcome == 0:
                code = Fore.CYAN + '😄'
                good += 1
            else:
                code = Fore.YELLOW + '😠'
                bad += 1
        else:
            code = Fore.BLUE + '🙅'

        print(
            '#', index, ' ', code, ' '
            'Category <', category, '> | '
            'Test <', name, '> | '
            'Actual <', 'pass' if outcome == 0 else 'FAIL', '>',
            Fore.RESET,
            sep='',
        )

    is_severe = severe > 0
    is_good = bad == 0
    code = (
        Fore.RED + '😱' if is_severe else
        Fore.CYAN + '😄' if is_good else
        Fore.YELLOW + '😠'
    )
    print()
    print(
        code, ' ',
        good, ' × correct outcome | ',
        bad, ' × wrong outcome | ',
        severe, ' × severe errors',
        Fore.RESET,
        sep=''
    )
    raise SystemExit(2 if is_severe else 0 if is_good else 1)

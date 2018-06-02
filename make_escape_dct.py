from os.path import join, abspath, dirname


def generate():
    unescaped = 0
    with open('./src/_escape_dct.hpp', 'wt') as f:
        print('const EscapeDct::Items EscapeDct::items = {', file=f)
        for c in range(0x100):
            if c == ord('\\'):
                s = '\\\\'
            elif c == ord('\b'):
                s = '\\b'
            elif c == ord('\f'):
                s = '\\f'
            elif c == ord('\n'):
                s = '\\n'
            elif c == ord('\r'):
                s = '\\r'
            elif c == ord('\t'):
                s = '\\t'
            elif (c < 0x20) or (c >= 0x7f) or (chr(c) in '''"'&<>\\'''):
                s = f'\\u{c:04x}'
            else:
                s = f'{c:c}'
                if c < 128:
                    unescaped |= 1 << c

            t = [
                f"'{c}'" if c != '\\' else f"'\\\\'"
                for c in s
            ] + ['0'] * 7
            t[7] = f'{len(s)}'
            print('    {' + ', '.join(t[:8]) + '},', file=f)
        print('};', file=f)

        escaped = unescaped ^ ((1 << 128) - 1)
        print('const unsigned __int128 EscapeDct::is_escaped_array = (', file=f)
        print(f'    ((unsigned __int128) 0x{(escaped >> 64):016x} << 64) |', file=f)
        print(f'    ((unsigned __int128) 0x{(escaped & ((1 << 64) - 1)):016x})', file=f)
        print(');', file=f)


if __name__ == '__main__':
    generate()

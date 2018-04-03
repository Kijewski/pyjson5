DEFAULT_MAX_NESTING_LEVEL = 32
UNLIMITED = -1


def decode_str(unicode data, object max_depth=None):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL
    return _decode_unicode(data, max_depth)


def decode_latin1(bytes data, object max_depth=None):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL
    return _decode_latin1(data, max_depth)


def decode(object data, object max_depth=None):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL

    if isinstance(data, unicode):
        return _decode_unicode(data, max_depth)
    elif isinstance(data, bytes):
        return _decode_latin1(data, max_depth)
    else:
        raise TypeError(f'type(data) == {type(data)!r} not supported')


__all__ = (
    'DEFAULT_MAX_NESTING_LEVEL', 'UNLIMITED',
    'decode_str', 'decode_latin1', 'decode',
)

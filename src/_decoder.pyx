DEFAULT_MAX_NESTING_LEVEL = 32
UNLIMITED = -1


cdef void _skip_single_line(ReaderRef reader) nogil:
    cdef uint32_t c0
    while _reader_good(reader):
        c0 = _reader_get(reader)
        if _is_line_terminator(c0):
            break


cdef boolean _skip_multiline_comment(ReaderRef reader) except False:
    cdef uint32_t c0
    cdef boolean seen_asterisk = False
    cdef Py_ssize_t comment_start = _reader_tell(reader)

    comment_start = _reader_tell(reader)

    seen_asterisk = False
    while _reader_good(reader):
        c0 = _reader_get(reader)
        if c0 == b'*':
            seen_asterisk = True
        elif seen_asterisk:
            if c0 == b'/':
                return True
            seen_asterisk = False

    raise Json5UnclosedComment(f'Unclosed comment starting near {comment_start}')


#    data found
# -1 exhausted
# -2 exception
cdef int32_t _skip_to_data(ReaderRef reader) except -2:
    cdef uint32_t c0
    cdef int32_t c1
    cdef boolean seen_slash

    seen_slash = False
    while True:
        if not _reader_good(reader):
            c1 = -1
            break
            
        c0 = _reader_get(reader)
        if c0 == b'/':
            if seen_slash:
                _skip_single_line(reader)
                seen_slash = False
            else:
                seen_slash = True

        elif c0 == b'*':
            if not seen_slash:
                raise Json5IllegalCharacter(f'Stray asterisk near {_reader_tell(reader)}')

            _skip_multiline_comment(reader)
            seen_slash = False

        elif _is_ws_zs(c0):
            if seen_slash:
                raise Json5IllegalCharacter(f'Stray slash near {_reader_tell(reader)}')

        else:
            c1 = cast_to_int32(c0)
            break

    if seen_slash:
        raise Json5IllegalCharacter(f'Stray slash near {_reader_tell(reader)}')

    return c1


cdef object _decode_string(ReaderRef reader, uint32_t delim):
    raise Json5Todo(f'TODO near {_reader_tell(reader)}')  # TODO


cdef object _decode_number(ReaderRef reader, uint32_t c0):
    raise Json5Todo(f'TODO near {_reader_tell(reader)}')  # TODO


cdef object _decode_object(ReaderRef reader):
    raise Json5Todo(f'TODO near {_reader_tell(reader)}')  # TODO


cdef object _decode_array(ReaderRef reader):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start
    cdef boolean needs_comma
    cdef object result = []
    cdef object datum

    start = _reader_tell(reader)
    needs_comma = False
    while True:
        c0 = _skip_to_data(reader)
        if c0 < 0:
            raise Json5EOF(f'Unclosed array starting near {start}')
        c1 = cast_to_uint32(c0)

        if c1 == b']':
            break
        elif c1 == b',':
            if not needs_comma:
                raise Json5IllegalCharacter(f'Stray comma near {_reader_tell(reader)}')
            needs_comma = False
            continue
        elif needs_comma:
            raise Json5IllegalCharacter(f'Expected `,` or `]` near {_reader_tell(reader)}')

        datum = _decode_recursive(reader, c1)
        result.append(datum)

        needs_comma = True
    return result


cdef boolean _accept_string(ReaderRef reader, const char *string) except False:
    cdef uint32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start

    start = _reader_tell(reader)
    while True:
        c0 = string[0]
        string += 1
        if not c0:
            break

        if not _reader_good(reader):
            raise Json5EOF('Truncated literal')

        c1 = _reader_get(reader)
        if c0 != c1:
            raise Json5IllegalCharacter(f'Expected: U+{c0:04X}, found: U+{c1:04X} in literal starting near {start}')

    return True


cdef object CONST_POS_NAN = float('+NaN')
cdef object CONST_POS_INF = float('+Infinity')
cdef object CONST_NEG_NAN = float('-NaN')
cdef object CONST_NEG_INF = float('-Infinity')


cdef object _decode_literal(ReaderRef reader, uint32_t c0):
    cdef const char *tail
    cdef object result

    if c0 == b'n':
        tail = b'ull'
        result = None
    elif c0 == b't':
        tail = b'rue'
        result = True
    elif c0 == b'f':
        tail = b'alse'
        result = False
    elif c0 == b'I':
        tail = b'nfinity'
        result = CONST_POS_INF
    else:  # elif c0 == b'N':
        tail = b'aN'
        result = CONST_POS_NAN

    _accept_string(reader, tail)
    return result


cdef object _decode_recursive_enter(ReaderRef reader, uint32_t c0):
    cdef object result

    _reader_enter(reader)
    Py_EnterRecursiveCall(' while decoding nested JSON5 object')
    try:
        if c0 == b'{':
            result = _decode_object(reader)
        else:
            result = _decode_array(reader)
    finally:
        Py_LeaveRecursiveCall()
        _reader_leave(reader)

    return result


cdef object _decoder_unknown(ReaderRef reader, uint32_t c0):
    raise Json5IllegalCharacter(f'Illegal character U+{c0:04X} near {_reader_tell(reader)}')


cdef object _decode_recursive(ReaderRef reader, uint32_t c0):
    cdef object (*fun)(ReaderRef, uint32_t)

    if c0 in b'ntfIN':
        fun = _decode_literal
    elif c0 in b'\'"':
        fun = _decode_string
    elif c0 in b'+-.0123456789':
        fun = _decode_number
    elif c0 in b'{[':
        fun = _decode_recursive_enter
    else:
        fun = _decoder_unknown

    return fun(reader, c0)


cdef boolean _expect_exhausted(ReaderRef reader) except False:
    cdef Py_ssize_t start
    cdef int32_t c0
    cdef uint32_t c1

    start = _reader_tell(reader)
    c0 = _skip_to_data(reader)
    if c0 >= 0:
        c1 = cast_to_uint32(c0)
        raise Json5ExtraData(f'Extra data U+{c1:04X} near {_reader_tell(reader)}')

    return True


cdef object _decode_all(ReaderRef reader):
    cdef Py_ssize_t start
    cdef int32_t c0
    cdef uint32_t c1
    cdef object result

    start = _reader_tell(reader)
    c0 = _skip_to_data(reader)
    if c0 < 0:
        raise Json5EOF(f'End of input near {start}')
    c1 = cast_to_uint32(c0)

    result = _decode_recursive(reader, c1)
    _expect_exhausted(reader)
    return result


cdef object _decode_ucs1(const Py_UCS1 *string, Py_ssize_t length, Py_ssize_t max_depth):
    cdef ReaderUCS1 reader = ReaderUCS1(string, length, 0, max_depth)
    return _decode_all(reader)


cdef object _decode_ucs2(const Py_UCS2 *string, Py_ssize_t length, Py_ssize_t max_depth):
    cdef ReaderUCS2 reader = ReaderUCS2(string, length, 0, max_depth)
    return _decode_all(reader)


cdef object _decode_ucs4(const Py_UCS4 *string, Py_ssize_t length, Py_ssize_t max_depth):
    cdef ReaderUCS4 reader = ReaderUCS4(string, length, 0, max_depth)
    return _decode_all(reader)


cdef object _decode_unicode(object data, Py_ssize_t max_depth):
    cdef Py_ssize_t length
    cdef int kind

    PyUnicode_READY(data)

    length = PyUnicode_GET_LENGTH(data)
    kind = PyUnicode_KIND(data)

    if kind == PyUnicode_1BYTE_KIND:
        return _decode_ucs1(PyUnicode_1BYTE_DATA(data), length, max_depth)
    elif kind == PyUnicode_2BYTE_KIND:
        return _decode_ucs2(PyUnicode_2BYTE_DATA(data), length, max_depth)
    else:  # elif kind == PyUnicode_4BYTE_KIND:
        return _decode_ucs4(PyUnicode_4BYTE_DATA(data), length, max_depth)


cdef object _decode_latin1(object data, Py_ssize_t max_depth=DEFAULT_MAX_NESTING_LEVEL):
    cdef char *string
    cdef Py_ssize_t length

    PyBytes_AsStringAndSize(data, &string, &length)
    return _decode_ucs1(<const Py_UCS1*> string, length, max_depth)


def decode_str(unicode data, Py_ssize_t max_depth=DEFAULT_MAX_NESTING_LEVEL):
    return _decode_unicode(data, max_depth)


def decode_latin1(bytes data, Py_ssize_t max_depth=DEFAULT_MAX_NESTING_LEVEL):
    return _decode_latin1(data, max_depth)


def decode(data, Py_ssize_t max_depth=DEFAULT_MAX_NESTING_LEVEL):
    if isinstance(data, unicode):
        return _decode_unicode(data, max_depth)
    elif isinstance(data, bytes):
        return _decode_latin1(data, max_depth)
    else:
        raise TypeError(f'type(data) == {type(data)!r} not supported')

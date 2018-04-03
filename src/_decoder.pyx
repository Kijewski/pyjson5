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
cdef int32_t _skip_to_data_sub(ReaderRef reader, uint32_t c0) except -2:
    cdef int32_t c1
    cdef boolean seen_slash

    seen_slash = False
    while True:
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

        if _reader_good(reader):
            c0 = _reader_get(reader)
        else:
            c1 = -1
            break

    if seen_slash:
        raise Json5IllegalCharacter(f'Stray slash near {_reader_tell(reader)}')

    return c1


#    data found
# -1 exhausted
# -2 exception
cdef int32_t _skip_to_data(ReaderRef reader) except -2:
    cdef uint32_t c0
    cdef int32_t c1
    if _reader_good(reader):
        c0 = _reader_get(reader)
        c1 = _skip_to_data_sub(reader, c0)
    else:
        c1 = -1
    return c1


cdef object _decode_string(ReaderRef reader, uint32_t delim):
    raise Json5Todo(f'TODO near {_reader_tell(reader)}')  # TODO


cdef object _decode_number(ReaderRef reader, uint32_t c0):
    raise Json5Todo(f'TODO near {_reader_tell(reader)}')  # TODO


#    data found
# -1 done
# -2 exception
cdef int32_t _skip_comma(
    ReaderRef reader,
    Py_ssize_t start,
    boolean *needs_comma,
    uint32_t terminator,
) except -2:
    cdef int32_t c0
    cdef uint32_t c1
    while True:
        c0 = _skip_to_data(reader)
        if c0 < 0:
            raise Json5EOF(f'Unclosed object or array starting near {start}')
        c1 = cast_to_uint32(c0)

        if c1 == terminator:
            c0 = -1
            break
        elif c1 == b',':
            if not needs_comma[0]:
                raise Json5IllegalCharacter(f'Stray comma near {_reader_tell(reader)}')
            needs_comma[0] = False
            continue
        elif needs_comma[0]:
            raise Json5IllegalCharacter(
                f'Expected comma or U+{terminator:04x} near {_reader_tell(reader)}, '
                f'found U+{c1:04x}'
            )

        c0 = _skip_to_data_sub(reader, c1)
        if c0 < 0:
            raise Json5EOF(f'Unclosed object or array starting near {start}')
        else:
            needs_comma[0] = True
            break

    return c0


# USES GIL!
cdef boolean _unicode_append(
    PyObject **buf_,
    Py_ssize_t *pos_,
    Py_ssize_t *length_,
    Py_UCS4 character
) nogil except False:
    cdef Py_UCS4 ucs4
    cdef Py_UCS4 *data
    cdef PyObject *buf = buf_[0]
    cdef Py_ssize_t pos = pos_[0]
    cdef Py_ssize_t length = length_[0]

    if buf is NULL:
        ucs4 = 0x10FFFF
        buf = UnicodeFromKindAndData(PyUnicode_4BYTE_KIND, &ucs4, 1)

    if pos == length:
        if length <= 0:
            length = 16
        else:
            length *= 2
        UnicodeResize(&buf, length)

    data = <Py_UCS4*> &((<CompactUnicodeObject*> buf)[1])
    data[pos] = character
    pos += 1

    buf_[0] = buf
    pos_[0] = pos
    length_[0] = length
    return True


cdef unicode _decode_identifier_name(ReaderRef reader, uint32_t *c_in_out):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start

    cdef PyObject *buf = NULL
    cdef Py_ssize_t pos = 0
    cdef Py_ssize_t length = 0

    start = _reader_tell(reader)
    try:
        c1 = c_in_out[0]
        if not _is_identifier_start(c1):
            raise Json5IllegalCharacter(
                f'Expected IdentifierStart near {_reader_tell(reader)}, '
                f'found U+{c1:04x}'
            )

        _unicode_append(&buf, &pos, &length, c1)

        while True:
            if not _reader_good(reader):
                raise Json5EOF(f'Unfinished IdentifierName starting near {start}')

            c1 = _reader_get(reader)
            if not _is_identifier_part(c1):
                c1 = cast_to_int32(c1)
                break

            _unicode_append(&buf, &pos, &length, c1)

        if pos < length:
            UnicodeResize(&buf, pos)

        c_in_out[0] = c1
        return <unicode> buf
    finally:
        XDecRef(buf)


cdef dict _decode_object(ReaderRef reader):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start
    cdef boolean needs_comma
    cdef dict result = {}
    cdef object key
    cdef object value

    start = _reader_tell(reader)
    needs_comma = False
    while True:
        c0 = _skip_comma(reader, start, &needs_comma, <unsigned char>b'}')
        if c0 < 0:
            break
        c1 = cast_to_uint32(c0)

        if c1 in b'"\'':
            key = _decode_string(reader, c1)
            c0 = _skip_to_data(reader)
        else:
            key = _decode_identifier_name(reader, &c1)
            c0 = _skip_to_data_sub(reader, c1)

        print(f'key={key!r}')

        if c0 < 0:
            raise Json5EOF(f'Unclosed object starting near {start}')
        c1 = cast_to_uint32(c0)

        value = _decode_recursive(reader, c1)
        result[key] = value
    return result


cdef list _decode_array(ReaderRef reader):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start
    cdef boolean needs_comma
    cdef list result = []
    cdef object datum

    start = _reader_tell(reader)
    needs_comma = False
    while True:
        c0 = _skip_comma(reader, start, &needs_comma, <unsigned char>b']')
        if c0 < 0:
            break
        c1 = cast_to_uint32(c0)

        datum = _decode_recursive(reader, c1)
        result.append(datum)
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


cdef object _decode_latin1(object data, Py_ssize_t max_depth):
    cdef char *string
    cdef Py_ssize_t length

    PyBytes_AsStringAndSize(data, &string, &length)
    return _decode_ucs1(<const Py_UCS1*> string, length, max_depth)

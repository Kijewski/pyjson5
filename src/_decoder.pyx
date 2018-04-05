cdef enum:
    NO_EXTRA_DATA = 0x0011_0000


cdef void _skip_single_line(ReaderRef reader) nogil:
    cdef uint32_t c0
    while _reader_good(reader):
        c0 = _reader_get(reader)
        if _is_line_terminator(c0):
            break


cdef int32_t _get_c_out(ReaderRef reader) nogil except -2:
    cdef uint32_t c0
    cdef int32_t c1

    if _reader_good(reader):
        c0 = _reader_get(reader)
        c1 = cast_to_int32(c0)
    else:
        c1 = -1

    return c1


cdef boolean _skip_multiline_comment(ReaderRef reader) nogil except False:
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

    return _raise_unclosed(b'comment', comment_start)


#     data found
# -1: exhausted
# -2: exception
cdef int32_t _skip_to_data_sub(ReaderRef reader, uint32_t c0) nogil except -2:
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
                _raise_stray_character('asterisk', _reader_tell(reader))

            _skip_multiline_comment(reader)
            seen_slash = False
        elif not _is_ws_zs(c0):
            c1 = cast_to_int32(c0)
            break
        elif seen_slash:
            _raise_stray_character('slash', _reader_tell(reader))
        elif not _reader_good(reader):
            c1 = -1
            break

        c0 = _reader_get(reader)

    if seen_slash:
        _raise_stray_character('slash', _reader_tell(reader))

    return c1


#    data found
# -1 exhausted
# -2 exception
cdef int32_t _skip_to_data(ReaderRef reader) nogil except -2:
    cdef uint32_t c0
    cdef int32_t c1
    if _reader_good(reader):
        c0 = _reader_get(reader)
        c1 = _skip_to_data_sub(reader, c0)
    else:
        c1 = -1
    return c1


cdef int32_t _get_hex_character(ReaderRef reader, Py_ssize_t length) nogil except -1:
    cdef Py_ssize_t start
    cdef uint32_t c0
    cdef uint32_t result
    cdef Py_ssize_t index

    start = _reader_tell(reader)
    result = 0
    for index in range(length):
        result <<= 4
        if not _reader_good(reader):
            _raise_unclosed(b'escape sequence', start)

        c0 = _reader_get(reader)
        if b'0' <= c0 <= b'9':
            result |= c0 - <uint32_t> b'0'
        elif b'a' <= c0 <= b'f':
            result |= c0 - <uint32_t> b'a' + 10
        elif b'A' <= c0 <= b'F':
            result |= c0 - <uint32_t> b'A' + 10
        else:
            _raise_expected_s('hexadecimal character', start, c0)

    if not (0 <= result <= 0x10ffff):
        _raise_expected_s('Unicode code point', start, result)

    return cast_to_int32(result)


# >=  0: character to append
#    -1: skip
# <  -1: -(next character + 1)
cdef int32_t _get_escape_sequence(ReaderRef reader, Py_ssize_t start) nogil except 0x7ffffff:
    cdef uint32_t c0
    cdef uint32_t c1

    c0 = _reader_get(reader)
    if not _reader_good(reader):
        _raise_unclosed(b'string', start)

    if c0 == b'b':
        return 0x0008
    elif c0 == b'f':
        return 0x000c
    elif c0 == b'n':
        return 0x000a
    elif c0 == b'r':
        return 0x000d
    elif c0 == b't':
        return 0x0009
    elif c0 == b'v':
        return 0x000b
    elif c0 == b'0':
        return 0x0000
    elif c0 == b'x':
        return _get_hex_character(reader, 2)
    elif c0 == b'u':
        c0 = cast_to_uint32(_get_hex_character(reader, 4))
        if not Py_UNICODE_IS_HIGH_SURROGATE(c0):
            return c0

        _accept_string(reader, b'\\u')

        c1 = cast_to_uint32(_get_hex_character(reader, 4))
        if not Py_UNICODE_IS_LOW_SURROGATE(c1):
            _raise_expected_s('low surrogate', start, c1)

        return Py_UNICODE_JOIN_SURROGATES(c0, c1)
    elif c0 == b'U':
        return _get_hex_character(reader, 8)
    elif b'1' <= c0 <= b'9':
        _raise_expected_s('escape sequence', start, c0)
        return -2
    elif _is_line_terminator(c0):
        if c0 != 0x000D:
            return -1

        c0 = _reader_get(reader)
        if c0 == 0x000A:
            return -1

        return -cast_to_int32(c0 + 1)
    else:
        return cast_to_int32(c0)


cdef object _decode_string_sub(ReaderRef reader, uint32_t delim, Py_ssize_t start, uint32_t c0):
    cdef int32_t c1
    cdef std_vector[uint32_t] buf

    while True:
        if c0 == delim:
            break

        if not _reader_good(reader):
            _raise_unclosed(b'string', start)

        if c0 != b'\\':
            buf.push_back(c0)
            c0 = _reader_get(reader)
            continue

        c1 = _get_escape_sequence(reader, start)
        if c1 >= -1:
            if not _reader_good(reader):
                _raise_unclosed(b'string', start)

            if c1 >= 0:
                c0 = cast_to_uint32(c1)
                buf.push_back(c0)

            c0 = _reader_get(reader)
        else:
            c0 = cast_to_uint32(-(c1 + 1))

    return PyUnicode_FromKindAndData(PyUnicode_4BYTE_KIND, buf.data(), buf.size())


cdef object _decode_string(ReaderRef reader, int32_t *c_in_out):
    cdef uint32_t delim
    cdef uint32_t c0
    cdef int32_t c1
    cdef Py_ssize_t start
    cdef object result

    c1 = c_in_out[0]
    delim = cast_to_uint32(c1)
    start = _reader_tell(reader)

    if not _reader_good(reader):
        _raise_unclosed(b'string', start)

    c0 = _reader_get(reader)
    result = _decode_string_sub(reader, delim, start, c0)

    c_in_out[0] = NO_EXTRA_DATA
    return result


cdef object _decode_number_leading_zero(ReaderRef reader, std_vector[char] &buf, int32_t *c_in_out):
    cdef uint32_t c0
    cdef int32_t c1
    cdef object pybuf

    if not _reader_good(reader):
        c_in_out[0] = -1
        return 0

    c0 = _reader_get(reader)
    if c0 in b'xX':
        while True:
            if not _reader_good(reader):
                c1 = -1
                break

            c0 = _reader_get(reader)
            if c0 in b'01233456789abcdefABCDEF':
                buf.push_back(<char> <unsigned char> c0)
            else:
                c1 = cast_to_int32(c0)
                break

        c_in_out[0] = c1
        pybuf = PyBytes_FromStringAndSize(buf.data(), buf.size())
        return int(pybuf, 16)
    elif c0 in b'.eE':
        buf.push_back('.')

        while True:
            if not _reader_good(reader):
                c1 = -1
                break

            c0 = _reader_get(reader)
            if c0 in b'0123456789.eE+-':
                buf.push_back(<char> <unsigned char> c0)
            else:
                c1 = cast_to_int32(c0)
                break

        c_in_out[0] = c1
        pybuf = PyBytes_FromStringAndSize(buf.data(), buf.size())
        return float(pybuf)
    else:
        c1 = _get_c_out(reader)
        c_in_out[0] = c1
        return 0


cdef object _decode_number_any(ReaderRef reader, std_vector[char] &buf, int32_t *c_in_out):
    cdef uint32_t c0
    cdef int32_t c1
    cdef boolean is_float
    cdef object pybuf

    c1 = c_in_out[0]
    c0 = cast_to_uint32(c1)

    is_float = False
    while True:
        if c0 in b'0123456789':
            pass
        elif c0 in b'abcdefABCDEF.+-':
            is_float = True
        else:
            c1 = cast_to_int32(c0)
            break

        buf.push_back(<char> <unsigned char> c0)

        if not _reader_good(reader):
            c1 = -1
            break

        c0 = _reader_get(reader)

    c_in_out[0] = c1

    pybuf = PyBytes_FromStringAndSize(buf.data(), buf.size())
    if is_float:
        return float(pybuf)
    else:
        return int(pybuf, 10)


cdef int32_t _accept_string_and_get_out(ReaderRef reader, const char *string) nogil except -2:
    _accept_string(reader, string)
    return _get_c_out(reader)


cdef object _decode_number(ReaderRef reader, int32_t *c_in_out):
    cdef uint32_t c0
    cdef int32_t c1
    cdef Py_ssize_t start
    cdef std_vector[char] buf

    c1 = c_in_out[0]
    c0 = cast_to_uint32(c1)

    if c0 == b'+':
        start = _reader_tell(reader)
        if not _reader_good(reader):
            _raise_unclosed(b'number', start)

        c0 = _reader_get(reader)
        if c0 == 'I':
            c1 = _accept_string_and_get_out(reader, b'nfinity')
            c_in_out[0] = c1
            return CONST_POS_INF
        elif c0 == b'N':
            c1 = _accept_string_and_get_out(reader, b'aN')
            c_in_out[0] = c1
            return CONST_POS_NAN

        buf.reserve(16)
    elif c0 == b'-':
        start = _reader_tell(reader)
        if not _reader_good(reader):
            _raise_unclosed(b'number', start)

        c0 = _reader_get(reader)
        if c0 == 'I':
            c1 = _accept_string_and_get_out(reader, b'nfinity')
            c_in_out[0] = c1
            return CONST_NEG_INF
        elif c0 == b'N':
            c1 = _accept_string_and_get_out(reader, b'aN')
            c_in_out[0] = c1
            return CONST_NEG_NAN

        buf.reserve(16)
        buf.push_back(b'-')
    else:
        buf.reserve(16)

    if c0 == b'0':
        return _decode_number_leading_zero(reader, buf, c_in_out)
    else:
        c1 = cast_to_int32(c0)
        c_in_out[0] = c1
        return _decode_number_any(reader, buf, c_in_out)


#  1: done
#  0: data found
# -1: exception (exhausted)
cdef uint32_t _skip_comma(
    ReaderRef reader,
    Py_ssize_t start,
    uint32_t terminator,
    const char *what,
    int32_t *c_in_out,
) nogil except -1:
    cdef int32_t c0
    cdef uint32_t c1
    cdef boolean needs_comma
    cdef uint32_t done

    c0 = c_in_out[0]
    c1 = cast_to_uint32(c0)

    needs_comma = True
    while True:
        c0 = _skip_to_data_sub(reader, c1)
        if c0 < 0:
            break

        c1 = cast_to_uint32(c0)
        if c1 == terminator:
            c0 = _get_c_out(reader)
            c_in_out[0] = c0
            return 1

        if c1 != b',':
            if needs_comma:
                _raise_expected_sc('comma', terminator, _reader_tell(reader), c1)
            c_in_out[0] = c0
            return 0

        if not needs_comma:
            _raise_stray_character('comma', _reader_tell(reader))

        if not _reader_good(reader):
            break

        c1 = _reader_get(reader)
        needs_comma = False

    _raise_unclosed(what, start)
    return -1


cdef unicode _decode_identifier_name(ReaderRef reader, int32_t *c_in_out):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start
    cdef std_vector[uint32_t] buf

    start = _reader_tell(reader)

    c0 = c_in_out[0]
    c1 = cast_to_uint32(c0)
    if not _is_identifier_start(c1):
        _raise_expected_s('IdentifierStart', _reader_tell(reader), c1)

    while True:
        buf.push_back(c1)

        if not _reader_good(reader):
            c0 = -1
            break

        c1 = _reader_get(reader)
        if not _is_identifier_part(c1):
            c0 = cast_to_int32(c1)
            break

    c_in_out[0] = c0
    return PyUnicode_FromKindAndData(PyUnicode_4BYTE_KIND, buf.data(), buf.size())


cdef dict _decode_object(ReaderRef reader):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start
    cdef boolean done
    cdef object key
    cdef object value
    cdef dict result = {}

    start = _reader_tell(reader)

    c0 = _skip_to_data(reader)
    if c0 >= 0:
        c1 = cast_to_uint32(c0)
        if c1 == b'}':
            return result

        while True:
            if c1 in b'"\'':
                key = _decode_string(reader, &c0)
            else:
                key = _decode_identifier_name(reader, &c0)
            if c0 < 0:
                break

            c1 = cast_to_uint32(c0)
            c0 = _skip_to_data_sub(reader, c1)
            if c0 < 0:
                break

            c1 = cast_to_uint32(c0)
            if c1 != b':':
                _raise_expected_s('colon', _reader_tell(reader), c1)

            if not _reader_good(reader):
                break

            c0 = _skip_to_data(reader)
            if c0 < 0:
                break

            value = _decode_recursive(reader, &c0)
            if c0 < 0:
                break

            result[key] = value

            done = _skip_comma(reader, start, <unsigned char>b'}', b'object', &c0)
            if done:
                return result

            c1 = cast_to_uint32(c0)

    _raise_unclosed(b'object', start)


cdef list _decode_array(ReaderRef reader):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start
    cdef boolean done
    cdef object value
    cdef list result = []

    start = _reader_tell(reader)

    c0 = _skip_to_data(reader)
    if c0 >= 0:
        c1 = cast_to_uint32(c0)
        if c1 == b']':
            return result

        while True:
            value = _decode_recursive(reader, &c0)
            if c0 < 0:
                break

            result.append(value)

            done = _skip_comma(reader, start, <unsigned char>b']', b'array', &c0)
            if done:
                return result

    _raise_unclosed(b'array', start)


cdef boolean _accept_string(ReaderRef reader, const char *string) nogil except False:
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
            _raise_unclosed(b'literal', start)

        c1 = _reader_get(reader)
        if c0 != c1:
            _raise_expected_c(c0, start, c1)

    return True


cdef object _decode_literal(ReaderRef reader, int32_t *c_in_out):
    cdef const char *tail
    cdef object result
    cdef uint32_t c0
    cdef int32_t c1

    c0 = cast_to_uint32(c_in_out[0])
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

    c_in_out[0] = NO_EXTRA_DATA
    return result


cdef object _decode_recursive_enter(ReaderRef reader, int32_t *c_in_out):
    cdef object result
    cdef int32_t c0
    cdef uint32_t c1

    c0 = c_in_out[0]
    c1 = cast_to_uint32(c0)

    _reader_enter(reader)
    try:
        if c0 == b'{':
            result = _decode_object(reader)
        else:
            result = _decode_array(reader)
    finally:
        _reader_leave(reader)

    c_in_out[0] = NO_EXTRA_DATA
    return result


cdef object _decoder_unknown(ReaderRef reader, int32_t *c_in_out):
    cdef int32_t c0
    cdef uint32_t c1
    cdef Py_ssize_t start

    c0 = c_in_out[0]
    c1 = cast_to_uint32(c0)
    start = _reader_tell(reader)

    _raise_expected_s('JSON5Value', start, c1)


cdef object _decode_recursive(ReaderRef reader, int32_t *c_in_out):
    cdef object (*decoder)(ReaderRef, int32_t*)
    cdef int32_t c0
    cdef uint32_t c1

    c0 = c_in_out[0]
    c1 = cast_to_uint32(c0)

    if c1 in b'ntfIN':
        decoder = _decode_literal
    elif c1 in b'\'"':
        decoder = _decode_string
    elif c1 in b'+-.0123456789':
        decoder = _decode_number
    elif c1 in b'{[':
        decoder = _decode_recursive_enter
    else:
        decoder = _decoder_unknown

    return decoder(reader, c_in_out)


cdef object _decode_all(ReaderRef reader, boolean some):
    cdef Py_ssize_t start
    cdef int32_t c0
    cdef uint32_t c1
    cdef object result

    start = _reader_tell(reader)
    c0 = _skip_to_data(reader)
    if c0 < 0:
        _raise_no_data(start)

    result = _decode_recursive(reader, &c0)
    if c0 < 0:
        pass
    elif not some:
        start = _reader_tell(reader)
        c1 = cast_to_uint32(c0)
        c0 = _skip_to_data_sub(reader, c1)
        if c0 >= 0:
            c1 = cast_to_uint32(c0)
            _raise_extra_data(c1, result, start)
    elif not _is_ws_zs(c0):
        start = _reader_tell(reader)
        c1 = cast_to_uint32(c0)
        _raise_unframed_data(c1, result, start)

    return result


cdef object _decode_ucs1(const Py_UCS1 *string, Py_ssize_t length, Py_ssize_t max_depth, boolean some):
    cdef ReaderUCS1 reader = ReaderUCS1(string, length, 0, max_depth)
    return _decode_all(reader, some)


cdef object _decode_ucs2(const Py_UCS2 *string, Py_ssize_t length, Py_ssize_t max_depth, boolean some):
    cdef ReaderUCS2 reader = ReaderUCS2(string, length, 0, max_depth)
    return _decode_all(reader, some)


cdef object _decode_ucs4(const Py_UCS4 *string, Py_ssize_t length, Py_ssize_t max_depth, boolean some):
    cdef ReaderUCS4 reader = ReaderUCS4(string, length, 0, max_depth)
    return _decode_all(reader, some)


cdef object _decode_unicode(object data, Py_ssize_t max_depth, boolean some):
    cdef Py_ssize_t length
    cdef int kind

    PyUnicode_READY(data)

    length = PyUnicode_GET_LENGTH(data)
    kind = PyUnicode_KIND(data)

    if kind == PyUnicode_1BYTE_KIND:
        return _decode_ucs1(PyUnicode_1BYTE_DATA(data), length, max_depth, some)
    elif kind == PyUnicode_2BYTE_KIND:
        return _decode_ucs2(PyUnicode_2BYTE_DATA(data), length, max_depth, some)
    elif kind == PyUnicode_4BYTE_KIND:
        return _decode_ucs4(PyUnicode_4BYTE_DATA(data), length, max_depth, some)
    else:
        pass  # impossible


cdef object _decode_latin1(object data, Py_ssize_t max_depth, boolean some):
    cdef char *string
    cdef Py_ssize_t length

    PyBytes_AsStringAndSize(data, &string, &length)
    return _decode_ucs1(<const Py_UCS1*> string, length, max_depth, some)


cdef object _decode_buffer(Py_buffer &view, int32_t word_length, Py_ssize_t max_depth, boolean some):
    if word_length == 1:
        return _decode_ucs1(<const Py_UCS1*> view.buf, view.len // 1, max_depth, some)
    elif word_length == 2:
        return _decode_ucs2(<const Py_UCS2*> view.buf, view.len // 2, max_depth, some)
    elif word_length == 4:
        return _decode_ucs4(<const Py_UCS4*> view.buf, view.len // 4, max_depth, some)
    else:
        raise ValueError('word_length must be 1, 2 or 4')


cdef object _decode_callable(PyObject *cb, Py_ssize_t max_depth, boolean some):
    cdef ReaderIterCodepoints reader = ReaderIterCodepoints(cb, -1, 0, max_depth)
    return _decode_all(reader, some)

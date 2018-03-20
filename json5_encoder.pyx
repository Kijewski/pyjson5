# distutils: language = c++
# cython: embedsignature = True

cimport cython
from libcpp cimport bool as boolean
from cython cimport typeof
from cython.operator cimport preincrement

cdef extern from 'Python.h':
    ctypedef signed char Py_UCS1
    ctypedef signed short Py_UCS2
    ctypedef signed long Py_UCS4

    enum:
        PyUnicode_1BYTE_KIND
        PyUnicode_2BYTE_KIND
        PyUnicode_4BYTE_KIND

    int PyUnicode_READY(object o) except -1
    Py_ssize_t PyUnicode_GET_LENGTH(object o)
    int PyUnicode_KIND(object o)
    Py_UCS1 *PyUnicode_1BYTE_DATA(object o)
    Py_UCS2 *PyUnicode_2BYTE_DATA(object o)
    Py_UCS4 *PyUnicode_4BYTE_DATA(object o)

    boolean Py_EnterRecursiveCall(const char *where) except True
    void Py_LeaveRecursiveCall()

ctypedef Py_UCS1 *string_UCS1
ctypedef Py_UCS2 *string_UCS2
ctypedef Py_UCS4 *string_UCS4

ctypedef string_UCS1 &string_ref_UCS1
ctypedef string_UCS2 &string_ref_UCS2
ctypedef string_UCS4 &string_ref_UCS4

cdef fused unicode_char:
    Py_UCS1
    Py_UCS2
    Py_UCS4

cdef fused unicode_string:
    string_UCS1
    string_UCS2
    string_UCS4

cdef fused unicode_string_ref:
    string_ref_UCS1
    string_ref_UCS2
    string_ref_UCS4


cdef enum JSON5Value_kind:
    INVALID
    J5Null, J5Boolean, J5String, J5Number, J5Object, J5Array


cdef class Json5EncoderException(Exception):
    pass

cdef class Json5ExtraData(Json5EncoderException):
    pass

cdef class Json5UnclosedComment(Json5EncoderException):
    pass

cdef class Json5Exhausted(Json5EncoderException):
    pass

cdef class Json5IllegalCharacter(Json5EncoderException):
    pass


cdef boolean _is_line_terminator(int c) nogil:
    # https://www.ecma-international.org/ecma-262/5.1/#sec-7.3
    return c in (
        0x000A,  # Line Feed <LF>
        0x000D,  # Carriage Return <CR>
        0x2028,  # Line separator <LS>
        0x2029,  # Paragraph separator <PS>
    )

cdef boolean _is_ws_zs(int c) nogil:
    return c in (
    # https://spec.json5.org/#white-space
        0x0009,  # Horizontal tab
        0x000A,  # Line feed
        0x000B,  # Vertical tab
        0x000C,  # Form feed
        0x000D,  # Carriage return
        0x0020,  # Space
        0x00A0,  # Non-breaking space
        0x2028,  # Line separator
        0x2029,  # Paragraph separator
        0xFEFF,  # Byte order mark
    # https://www.fileformat.info/info/unicode/category/Zs/list.htm
        0x0020,  # SPACE
        0x00A0,  # NO-BREAK SPACE
        0x1680,  # OGHAM SPACE MARK
        0x2000,  # EN QUAD
        0x2001,  # EM QUAD
        0x2002,  # EN SPACE
        0x2003,  # EM SPACE
        0x2004,  # THREE-PER-EM SPACE
        0x2005,  # FOUR-PER-EM SPACE
        0x2006,  # SIX-PER-EM SPACE
        0x2007,  # FIGURE SPACE
        0x2008,  # PUNCTUATION SPACE
        0x2009,  # THIN SPACE
        0x200A,  # HAIR SPACE
        0x202F,  # NARROW NO-BREAK SPACE
        0x205F,  # MEDIUM MATHEMATICAL SPACE
        0x3000,  # IDEOGRAPHIC SPACE
    )


cdef inline void _advance(unicode_string_ref data, Py_ssize_t &remaining, Py_ssize_t amount=1) nogil:
    (&data)[0] += amount
    (&remaining)[0] -= amount


cdef void _skip_single_line(unicode_string_ref data, Py_ssize_t &remaining) nogil:
    cdef int c0
    while remaining > 0:
        c0 = data[0]
        _advance(data, remaining)
        if _is_line_terminator(c0):
            return


cdef boolean _skip_multiline_comment(unicode_string_ref data, Py_ssize_t &remaining) except False:
    cdef int c1
    cdef int c0
    cdef Py_ssize_t comment_start = remaining
    while True:
        if remaining < 2:
            raise Json5UnclosedComment(f'remaining={comment_start}')

        c1 = data[1]
        if c1 != b'/':
            if c1 != b'*':
                _advance(data, remaining, 2)
            else:
                _advance(data, remaining)
        else:
            c0 = data[0]
            _advance(data, remaining, 2)
            if c0 == b'*':
                return True


cdef boolean _skip_to_data(unicode_string_ref data, Py_ssize_t &remaining) except False:
    cdef int c0
    cdef int c1
    while True:
        c0 = data[0]
        if (remaining >= 1) and _is_ws_zs(c0):
            _advance(data, remaining)
        elif (remaining >= 2) and (c0 == b'/'):
            c1 = data[1]
            if c1 == b'/':
                _advance(data, remaining, 2)
                _skip_single_line(data, remaining)
            elif c1 == b'*':
                _advance(data, remaining, 2)
                if not _skip_multiline_comment(data, remaining):
                    raise Json5ExtraData(f'')
            else:
                return True
        else:
            return True


cdef JSON5Value_kind _devine_kind(int c) nogil:
    if c in b'n':
        return JSON5Value_kind.J5Null
    elif c in b'tf':
        return JSON5Value_kind.J5Boolean
    elif c in b'\'"':
        return JSON5Value_kind.J5String
    elif c in b'+-.IN0123456789':
        return JSON5Value_kind.J5Number
    elif c in b'{':
        return JSON5Value_kind.J5Object
    elif c in b'[':
        return JSON5Value_kind.J5Array
    else:
        return JSON5Value_kind.INVALID


cdef object _decode_null(unicode_string_ref data, Py_ssize_t &remaining):
    return '''TODO'''


cdef object _decode_boolean(unicode_string_ref data, Py_ssize_t &remaining):
    return '''TODO'''


cdef object _decode_string(unicode_string_ref data, Py_ssize_t &remaining):
    return '''TODO'''


cdef object _decode_number(unicode_string_ref data, Py_ssize_t &remaining):
    return '''TODO'''


cdef object _decode_object(unicode_string_ref data, Py_ssize_t &remaining):
    return '''TODO'''


cdef object _decode_array(unicode_string_ref data, Py_ssize_t &remaining):
    return '''TODO'''


cdef object _decode(unicode_string_ref data, Py_ssize_t &remaining):
    cdef Py_ssize_t decode_start = remaining
    cdef int c0
    cdef JSON5Value_kind kind

    Py_EnterRecursiveCall(' while decoding nested JSON5 object')
    try:
        _skip_to_data(data, remaining)
        if remaining <= 0:
            raise Json5UnclosedComment(f'remaining={decode_start}')

        c0 = data[0]
        kind = _devine_kind(c0)
        if kind == JSON5Value_kind.J5Null:
            return _decode_null(data, remaining)
        elif kind == JSON5Value_kind.J5Boolean:
            return _decode_boolean(data, remaining)
        elif kind == JSON5Value_kind.J5String:
            return _decode_string(data, remaining)
        elif kind == JSON5Value_kind.J5Number:
            return _decode_number(data, remaining)
        elif kind == JSON5Value_kind.J5Object:
            return _decode_object(data, remaining)
        elif kind == JSON5Value_kind.J5Array:
            return _decode_array(data, remaining)
        elif kind == JSON5Value_kind.INVALID:
            raise Json5IllegalCharacter(f'remaining={decode_start}')
    finally:
        Py_LeaveRecursiveCall()


def decode(unicode data):
    cdef int kind
    cdef Py_ssize_t remaining
    cdef Py_UCS1 *buf1
    cdef Py_UCS2 *buf2
    cdef Py_UCS4 *buf4
    cdef object result

    PyUnicode_READY(data)

    remaining = PyUnicode_GET_LENGTH(data)

    kind = PyUnicode_KIND(data)
    if kind == PyUnicode_1BYTE_KIND:
        buf1 = PyUnicode_1BYTE_DATA(data)
        result = _decode(buf1, remaining)
    elif kind == PyUnicode_2BYTE_KIND:
        buf2 = PyUnicode_2BYTE_DATA(data)
        result = _decode(buf2, remaining)
    else:
        buf4 = PyUnicode_4BYTE_DATA(data)
        result = _decode(buf4, remaining)

    if remaining != 0:
        raise Json5ExtraData(f'remaining={remaining}')

    return result

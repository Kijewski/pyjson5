cdef boolean _is_line_terminator(uint32_t c) nogil:
    # https://www.ecma-international.org/ecma-262/5.1/#sec-7.3
    if expect(c <= 0x00FF, True):
        return c in (
            0x000A,  # Line Feed <LF>
            0x000D,  # Carriage Return <CR>
        )
    elif expect(c <= 0xFFFF, True):
        return c in (
            0x2028,  # Line separator <LS>
            0x2029,  # Paragraph separator <PS>
        )
    else:
        return False


cdef boolean _is_ws_zs(uint32_t c) nogil:
    # https://spec.json5.org/#white-space
    # https://www.fileformat.info/info/unicode/category/Zs/list.htm
    if expect(c <= 0x00FF, True):
        return c in (
            0x0009,  # Horizontal tab
            0x000A,  # Line feed
            0x000B,  # Vertical tab
            0x000C,  # Form feed
            0x000D,  # Carriage return
            0x0020,  # Space
            0x0020,  # SPACE
            0x00A0,  # NO-BREAK SPACE
            0x00A0,  # Non-breaking space
        )
    elif expect(c <= 0xFFFF, True):
        return c in (
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
            0x2028,  # Line separator
            0x2029,  # Paragraph separator
            0x202F,  # NARROW NO-BREAK SPACE
            0x205F,  # MEDIUM MATHEMATICAL SPACE
            0x3000,  # IDEOGRAPHIC SPACE
            0xFEFF,  # Byte order mark
        )
    else:
        return c in (
            NO_EXTRA_DATA,
        )


cdef boolean _is_pc(uint32_t c) nogil:
    # http://www.fileformat.info/info/unicode/category/Pc/list.htm
    if expect(c <= 0x00FF, True):
        return c in (
            0x005F,  # LOW LINE
        )
    elif expect(c <= 0xFFFF, True):
        return c in (
            0x203F,  # UNDERTIE
            0x2040,  # CHARACTER TIE
            0x2054,  # INVERTED UNDERTIE
            0xFE33,  # PRESENTATION FORM FOR VERTICAL LOW LINE
            0xFE34,  # PRESENTATION FORM FOR VERTICAL WAVY LOW LINE
            0xFE4D,  # DASHED LOW LINE
            0xFE4E,  # CENTRELINE LOW LINE
            0xFE4F,  # WAVY LOW LINE
            0xFF3F,  # FULLWIDTH LOW LINE
        )
    else:
        return False


cdef boolean _is_identifier_start(uint32_t c) nogil:
    return (
        (b'A' <= c <= b'Z') or
        (b'a' <= c <= b'z') or
        (c in b'$_') or
        Py_UNICODE_ISALPHA(c) or
        False
    )


cdef boolean _is_identifier_part(uint32_t c) nogil:
    return (
        # IdentifierStart
        _is_identifier_start(c) or
        # UnicodeCombiningMark
        _is_mn(c) or
        _is_mc(c) or
        # UnicodeDigit
        Py_UNICODE_ISDIGIT(c) or
        # UnicodeConnectorPunctuation
        _is_pc(c) or
        # ZWNJ and ZWJ
        (c in (0x200C, 0x200D)) or
        False
    )


cdef inline boolean _is_x(uint32_t c) nogil:
    return (c | 0x20) == b'x'

cdef inline boolean _is_e(uint32_t c) nogil:
    return (c | 0x20) == b'e'

cdef inline boolean _is_decimal(uint32_t c) nogil:
    return b'0' <= c <= b'9'

cdef inline boolean _is_hex(uint32_t c) nogil:
    return b'a' <= (c | 0x20) <= b'f'

cdef inline boolean _is_hexadecimal(uint32_t c) nogil:
    return _is_decimal(c) or _is_hex(c)

cdef boolean _is_in_float_representation(uint32_t c) nogil:
    if _is_decimal(c):
        return True
    if _is_e(c):
        return True
    elif c in b'.+-':
        return True
    else:
        return False

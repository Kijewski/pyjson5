cdef boolean _is_line_terminator(uint32_t c) nogil:
    # https://www.ecma-international.org/ecma-262/5.1/#sec-7.3
    return c in (
        0x000A,  # Line Feed <LF>
        0x000D,  # Carriage Return <CR>
        0x2028,  # Line separator <LS>
        0x2029,  # Paragraph separator <PS>
    )


cdef boolean _is_ws_zs(uint32_t c) nogil:
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

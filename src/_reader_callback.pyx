cdef struct ReaderCallback:
    Py_object *callback
    Py_object *args
    Py_ssize_t position
    Py_ssize_t maxdepth
    int32_t lookahead


cdef inline uint32_t _reader_Callback_get(ReaderCallback self):
    cdef int32_t c = self.lookahead

    self.lookahead = -1
    self.position += 1

    return cast_to_uint32(c)


cdef inline Py_ssize_t _reader_Callback_tell(ReaderCallback self):
    return self.base.position


cdef int32_t _reader_Callback_good(ReaderCallback self) except -1:
    cdef Py_ssize_t c

    cdef object value = CallObject(self.callback, self.args)
    if (value is None) or (value is False):
        return False

    if isinstance(value, int):
        c = value
    elif isinstance(value, ORD_CLASSES):
        if not value:
            return False
        c = ord(value)
    else:
        raise TypeError(f'type(value)=={type(value)!r} not in (int, str, bytes)')

    if c < 0:
        return False
    elif c > 0x10ffff:
        raise ValueError(f'Ordinal value=={c!r} is invalid.')

    self.lookahead = c

    return True

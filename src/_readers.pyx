cdef struct ReaderUCS1:
    const Py_UCS1 *string
    Py_ssize_t remaining
    Py_ssize_t position
    Py_ssize_t max_depth


cdef struct ReaderUCS2:
    const Py_UCS2 *string
    Py_ssize_t remaining
    Py_ssize_t position
    Py_ssize_t max_depth


cdef struct ReaderUCS4:
    const Py_UCS4 *string
    Py_ssize_t remaining
    Py_ssize_t position
    Py_ssize_t max_depth


ctypedef ReaderUCS1 &ReaderUCS1Ref
ctypedef ReaderUCS2 &ReaderUCS2Ref
ctypedef ReaderUCS4 &ReaderUCS4Ref

ctypedef Py_UCS1 *UCS1String
ctypedef Py_UCS2 *UCS2String
ctypedef Py_UCS4 *UCS4String

ctypedef fused Reader:
    ReaderUCS1
    ReaderUCS2
    ReaderUCS4

ctypedef fused ReaderRef:
    ReaderUCS1Ref
    ReaderUCS2Ref
    ReaderUCS4Ref

ctypedef fused UCSChar:
    Py_UCS1
    Py_UCS2
    Py_UCS4

ctypedef fused UCSString:
    UCS1String
    UCS2String
    UCS4String


cdef Py_ssize_t _reader_tell(ReaderRef self) nogil:
    return self.position


cdef boolean _reader_good(ReaderRef self) nogil:
    return (self.remaining > 0)


cdef uint32_t _reader_get(ReaderRef self) nogil:
    cdef uint32_t c0 = cast_to_uint32(self.string[0])
    self.string += 1
    self.position += 1
    self.remaining -= 1
    return c0


cdef boolean _reader_enter(ReaderRef self) except False:
    self.max_depth -= 1
    if self.max_depth == 0:
        raise Json5NestingTooDeep('Maximum nesting level exceeded')
    return True


cdef void _reader_leave(ReaderRef self) nogil:
    self.max_depth += 1

cdef struct ReaderUCS:
    Py_ssize_t remaining
    Py_ssize_t position
    Py_ssize_t maxdepth


cdef struct ReaderUCS1:
    ReaderUCS base
    const Py_UCS1 *string


cdef struct ReaderUCS2:
    ReaderUCS base
    const Py_UCS2 *string


cdef struct ReaderUCS4:
    ReaderUCS base
    const Py_UCS4 *string


ctypedef ReaderUCS1 &ReaderUCS1Ref
ctypedef ReaderUCS2 &ReaderUCS2Ref
ctypedef ReaderUCS4 &ReaderUCS4Ref

ctypedef Py_UCS1 *UCS1String
ctypedef Py_UCS2 *UCS2String
ctypedef Py_UCS4 *UCS4String

ctypedef fused ReaderUCSRef:
    ReaderUCS1Ref
    ReaderUCS2Ref
    ReaderUCS4Ref

ctypedef fused UCSString:
    UCS1String
    UCS2String
    UCS4String


cdef inline int32_t _reader_ucs_good(ReaderUCSRef self):
    return self.base.remaining > 0


cdef inline uint32_t _reader_ucs_get(ReaderUCSRef self):
    cdef int32_t c = self.string[0]

    self.string += 1
    self.base.remaining -= 1
    self.base.position += 1

    return cast_to_uint32(c)

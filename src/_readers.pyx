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


cdef struct ReaderIterCodepoints:
    PyObject *get_next
    int32_t lookahead
    Py_ssize_t position
    Py_ssize_t max_depth


ctypedef ReaderUCS1 &ReaderUCS1Ref
ctypedef ReaderUCS2 &ReaderUCS2Ref
ctypedef ReaderUCS4 &ReaderUCS4Ref
ctypedef ReaderIterCodepoints &ReaderIterCodepointsRef

ctypedef Py_UCS1 *UCS1String
ctypedef Py_UCS2 *UCS2String
ctypedef Py_UCS4 *UCS4String

ctypedef fused ReaderTrivialRef:
    ReaderUCS1Ref
    ReaderUCS2Ref
    ReaderUCS4Ref

ctypedef fused ReaderComplexRef:
    ReaderIterCodepointsRef

ctypedef fused ReaderRef:
    ReaderTrivialRef
    ReaderComplexRef

ctypedef fused UCSChar:
    Py_UCS1
    Py_UCS2
    Py_UCS4

ctypedef fused UCSString:
    UCS1String
    UCS2String
    UCS4String


cdef inline Py_ssize_t _reader_tell(ReaderRef self) nogil:
    return self.position


cdef inline boolean _reader_enter(ReaderRef self) except False:
    self.max_depth -= 1
    if self.max_depth == 0:
        raise Json5NestingTooDeep('Maximum nesting level exceeded')

    Py_EnterRecursiveCall(' while decoding nested JSON5 object')

    return True


cdef inline void _reader_leave(ReaderRef self):
    Py_LeaveRecursiveCall()
    self.max_depth += 1


cdef inline int32_t _reader_good(ReaderRef self) nogil except -1:
    if ReaderRef in ReaderTrivialRef:
        return self.remaining > 0
    elif ReaderRef in ReaderComplexRef:
        return (self.lookahead >= 0) or _reader_good_fill(self)


cdef inline uint32_t _reader_get(ReaderRef self) nogil:
    cdef int32_t c0
    cdef uint32_t c1

    if ReaderRef in ReaderTrivialRef:
        c0 = self.string[0]

        self.string += 1
        self.remaining -= 1
    elif ReaderRef in ReaderComplexRef:
        c0 = self.lookahead

        self.lookahead = -1

    self.position += 1
    c1 = cast_to_uint32(c0)
    return c1


cdef int32_t _reader_good_fill(ReaderIterCodepointsRef self) nogil except -1:
    cdef uint32_t result

    if self.get_next is NULL:
        return False

    with gil:
        try:
            result = (<object> self.get_next)()
            if result > 0x10_ffff:
                raise ValueError(f'result={result!r} is not a valid Unicode codepoint')
            self.lookahead = cast_to_int32(result)

            return True
        except StopIteration:
            self.get_next = NULL
            self.lookahead = -1
            return False
        except BaseException:
            self.get_next = NULL
            self.lookahead = -1
            raise

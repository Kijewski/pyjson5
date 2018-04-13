ctypedef fused ReaderRef:
    ReaderUCSRef
    ReaderCallbackRef


cdef boolean _reader_enter(ReaderRef self) except False:
    if self.base.maxdepth == 0:
        raise Json5NestingTooDeep('Maximum nesting level exceeded')

    self.base.maxdepth -= 1
    Py_EnterRecursiveCall(' while decoding nested JSON5 object')

    return True


cdef void _reader_leave(ReaderRef self):
    Py_LeaveRecursiveCall()
    self.base.maxdepth += 1


cdef inline Py_ssize_t _reader_tell(ReaderRef self):
    if ReaderRef in ReaderUCSRef:
        return _reader_ucs_tell(self)
    elif ReaderRef in ReaderCallbackRef:
        return _reader_callback_tell(self)


cdef inline uint32_t _reader_get(ReaderRef self):
    if ReaderRef in ReaderUCSRef:
        return _reader_ucs_get(self)
    elif ReaderRef in ReaderCallbackRef:
        return _reader_callback_get(self)


cdef int32_t _reader_good(ReaderRef self) except -1:
    if ReaderRef in ReaderUCSRef:
        return _reader_ucs_good(self)
    elif ReaderRef in ReaderCallbackRef:
        return _reader_callback_good(self)

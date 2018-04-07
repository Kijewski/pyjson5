cdef struct WriterCallback:
    Writer base
    PyObject *callback


cdef boolean _WriterCallback_reserve(WriterRef writer_, size_t amount) except False:
    cdef WriterCallback *writer = <WriterCallback*> &writer_

    if amount < 0:
        return True

    pass

    return True


cdef boolean _WriterCallback_append_c(Writer &writer_, char datum) except False:
    cdef WriterCallback *writer = <WriterCallback*> &writer_

    CallFunction(writer.callback, b'C', datum)

    return True


cdef boolean _WriterCallback_append_s(Writer &writer_, const char *s, Py_ssize_t length) except False:
    cdef WriterCallback *writer = <WriterCallback*> &writer_

    if length < 0:
        return True

    CallFunction(writer.callback, b'U#', s, <int> length)

    return True

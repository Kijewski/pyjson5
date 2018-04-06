cdef struct WriterVector:
    std_vector[char] buf


cdef struct WriterDelegated:
    boolean (*append_c)(WriterDelegated *writer, char datum) nogil except False
    boolean (*append_s)(WriterDelegated *writer, const char *s, Py_ssize_t length) nogil except False


cdef struct WriterCallback:
    PyObject *callback


ctypedef WriterVector &WriterVectorRef
ctypedef WriterDelegated &WriterDelegatedRef
ctypedef WriterCallback &WriterCallbackRef


ctypedef fused WriterRef:
    WriterVectorRef
    WriterDelegatedRef
    WriterCallbackRef


cdef boolean _writer_reserve(WriterRef writer, size_t amount) nogil except False:
    if WriterRef is WriterVectorRef:
        if amount > 0:
            writer.buf.reserve(writer.buf.size() + amount)
    elif WriterRef is WriterDelegated:
        pass
    elif WriterRef is WriterCallbackRef:
        pass
    return True


cdef inline boolean _writer_append_c(WriterRef writer, char datum) nogil except False:
    if WriterRef is WriterVectorRef:
        writer.buf.push_back(datum)
    elif WriterRef is WriterDelegated:
        writer.append_c(&writer, datum)
    elif WriterRef is WriterCallbackRef:
        with gil:
            CallFunction(writer.callback, b'C', datum)
    return True


cdef inline boolean _writer_append_i(WriterRef writer, Py_ssize_t index) nogil except False:
    cdef const char *s
    cdef Py_ssize_t length

    s = &ESCAPE_DCT.items[index][0]
    length = s[7]
    if length == 1:
        _writer_append_c(writer, s[0])
    else:
        _writer_append_s(writer, s, length)

    return True


cdef boolean _writer_append_s(WriterRef writer, const char *s, Py_ssize_t length) nogil except False:
    cdef size_t position

    if WriterRef is WriterVectorRef:
        if length > 0:
            position = writer.buf.size()
            writer.buf.resize(position + length)
            memcpy(writer.buf.data() + position, s, length)
    elif WriterRef is WriterDelegated:
        writer.append_s(&writer, s, length)
    elif WriterRef is WriterCallbackRef:
        with gil:
            CallFunction(writer.callback, b'U#', s, <int> length)

    return True

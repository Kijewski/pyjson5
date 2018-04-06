cdef struct WriterVector:
    std_vector[char] buf


cdef struct WriterDelegated:
    boolean (*append_c)(WriterDelegated *writer, char datum) nogil except False
    boolean (*append_s)(WriterDelegated *writer, const char *s, Py_ssize_t length) nogil except False


ctypedef WriterVector &WriterVectorRef


ctypedef fused WriterRef:
    WriterVectorRef


cdef boolean _writer_reserve(WriterRef writer, size_t amount) nogil except False:
    if WriterRef is WriterVectorRef:
        if amount > 0:
            writer.buf.reserve(writer.buf.size() + amount)
    elif WriterRef is WriterDelegated:
        pass
    return True


cdef inline boolean _writer_append_c(WriterRef writer, char datum) nogil except False:
    if WriterRef is WriterVectorRef:
        writer.buf.push_back(datum)
    elif WriterRef is WriterDelegated:
        writer.append_c(&writer, datum)
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
    return True

cdef struct WriterVector:
    std_vector[char] buf


ctypedef WriterVector &WriterVectorRef


ctypedef fused WriterRef:
    WriterVectorRef


cdef boolean _writer_reserve(WriterRef writer, size_t amount) nogil except False:
    cdef size_t position
    if WriterRef is WriterVectorRef:
        if amount > 0:
            position = writer.buf.size()
            writer.buf.reserve(position + amount)
        return True


cdef boolean _writer_append_c(WriterRef writer, char datum) nogil except False:
    if WriterRef is WriterVectorRef:
        writer.buf.push_back(datum)
        return True


cdef boolean _writer_append_i(WriterRef writer, Py_ssize_t index) nogil except False:
    cdef Py_ssize_t length
    cdef const char *s

    s = &ESCAPE_DCT.items[index][0]
    length = s[7]
    _writer_append_s(writer, s, length)

    return True


cdef boolean _writer_append_s(WriterRef writer, const char *s, Py_ssize_t length) nogil except False:
    cdef size_t position
    cdef char *tail
    if WriterRef is WriterVectorRef:
        if length > 0:
            position = writer.buf.size()
            writer.buf.resize(position + length)
            memcpy(writer.buf.data() + position, s, length)
        return True

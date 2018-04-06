cdef struct WriterVector:
    std_vector[char] buf


ctypedef WriterVector &WriterVectorRef


ctypedef fused WriterRef:
    WriterVectorRef


cdef boolean _writer_reserve(WriterRef writer, size_t amount) nogil except False:
    cdef size_t cur_size
    if WriterRef is WriterVector:
        cur_size = writer.buf.size()
        writer.buf.reserve(cur_size + amount)
        return True


cdef boolean _writer_append_c(WriterRef writer, char datum) nogil except False:
    if WriterRef is WriterVector:
        writer.buf.push_back(datum)
        return True


cdef boolean _writer_append_i(WriterRef writer, Py_ssize_t index) nogil except False:
    cdef size_t length
    cdef const char *item

    item = &ESCAPE_DCT.items[index][0]
    length = item[7]
    if length == 1:
        _writer_append_c(writer, item[0])
    else:
        _writer_append_sz(writer, item, length)

    return True


cdef boolean _writer_append_s(WriterRef writer, const char *s) nogil except False:
    cdef size_t length
    if s is not NULL:
        length = strlen(s)
        if length == 0:
            pass
        elif length == 1:
            _writer_append_c(writer, s[0])
        else:
            _writer_append_sz(writer, s, length)
    return True


cdef boolean _writer_append_sz(WriterRef writer, const char *s, size_t length) nogil except False:
    cdef size_t cur_size
    if WriterRef is WriterVector:
        if length <= 0:
            pass
        elif length == 1:
            writer.buf.push_back(s[0])
        else:
            cur_size = writer.buf.size()
            writer.buf.resize(cur_size + length)
            memcpy(writer.buf.data() + cur_size, s, length)
        return True

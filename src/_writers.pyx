cdef struct WriterVector:
    std_vector[char] buf


cdef struct WriterDelegated:
    boolean (*append_c)(WriterDelegated *writer, char datum) nogil except False
    boolean (*append_s)(WriterDelegated *writer, const char *s, Py_ssize_t length) nogil except False


cdef struct WriterCallback:
    PyObject *callback


cdef struct WriterUnicode:
    size_t position
    size_t length
    AsciiObject *obj


ctypedef WriterVector &WriterVectorRef
ctypedef WriterDelegated &WriterDelegatedRef
ctypedef WriterCallback &WriterCallbackRef
ctypedef WriterUnicode &WriterUnicodeRef


ctypedef fused WriterRef:
    WriterVectorRef
    WriterDelegatedRef
    WriterCallbackRef
    WriterUnicodeRef


cdef boolean _writer_reserve(WriterRef writer, size_t amount) nogil except False:
    cdef size_t current_size
    cdef size_t needed_size
    cdef size_t new_size
    cdef size_t increment
    cdef size_t max_increment
    cdef void *new_obj

    if amount > 0:
        if WriterRef is WriterVectorRef:
            writer.buf.reserve(writer.buf.size() + amount)
        elif WriterRef is WriterDelegated:
            pass
        elif WriterRef is WriterCallbackRef:
            pass
        elif WriterRef is WriterUnicodeRef:
            needed_size = writer.position + amount
            current_size = writer.length
            if needed_size >= current_size:
                new_size = current_size
                while new_size <= needed_size:
                    new_size = (new_size + 32) + (new_size // 4)

                max_increment = 32768
                if amount >= max_increment:
                    max_increment += amount

                increment = current_size - new_size
                if increment > max_increment:
                    new_size = current_size + max_increment

                with gil:
                    new_obj = ObjectRealloc(writer.obj, new_size + sizeof(PyASCIIObject) + 1)
                    if new_obj is NULL:
                        ErrNoMemory()

                writer.obj = <AsciiObject*> new_obj
                writer.length = new_size

    return True


cdef inline boolean _writer_append_c(WriterRef writer, char datum) nogil except False:
    if WriterRef is WriterVectorRef:
        writer.buf.push_back(datum)
    elif WriterRef is WriterDelegated:
        writer.append_c(&writer, datum)
    elif WriterRef is WriterCallbackRef:
        with gil:
            CallFunction(writer.callback, b'C', datum)
    elif WriterRef is WriterUnicodeRef:
        _writer_reserve(writer, 1)
        writer.obj.data[writer.position] = datum
        writer.position += 1

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

    if length > 0:
        if WriterRef is WriterVectorRef:
            position = writer.buf.size()
            writer.buf.resize(position + length)
            memcpy(writer.buf.data() + position, s, length)
        elif WriterRef is WriterDelegated:
            writer.append_s(&writer, s, length)
        elif WriterRef is WriterCallbackRef:
            with gil:
                CallFunction(writer.callback, b'U#', s, <int> length)
        elif WriterRef is WriterUnicodeRef:
            _writer_reserve(writer, length)
            memcpy(writer.obj.data + writer.position, s, length)
            writer.position += length

    return True

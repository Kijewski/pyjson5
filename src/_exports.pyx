DEFAULT_MAX_NESTING_LEVEL = 32
UNLIMITED = -1
TO_JSON = None


def decode(object data, object max_depth=None, boolean some=False):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL

    if isinstance(data, unicode):
        return _decode_unicode(data, max_depth, some)
    else:
        raise TypeError(f'type(data) == {type(data)!r} not supported')


def decode_latin1(object data, object max_depth=None, boolean some=False):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL
    return _decode_latin1(data, max_depth, some)


def decode_buffer(object obj, int32_t word_length=1, object max_depth=None, boolean some=False):
    cdef Py_buffer view

    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL

    PyObject_GetBuffer(obj, &view, PyBUF_CONTIG_RO)
    try:
        return _decode_buffer(view, word_length, max_depth, some)
    finally:
        PyBuffer_Release(&view)


def decode_iter(object cb, object max_depth=None, boolean some=False):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL

    if not callable(cb):
        try:
            cb = iter(cb).__next__
        except Exception as ex:
            raise TypeError('cb must be callable') from ex

    return _decode_callable(<PyObject*> cb, max_depth, some)


def encode(data):
    cdef WriterVector writer
    _encode(writer, data)
    return PyUnicode_FromKindAndData(PyUnicode_1BYTE_KIND, writer.buf.data(), writer.buf.size())


def encode_unicode(data):
    cdef void *temp = NULL
    cdef object result
    cdef WriterUnicode writer = WriterUnicode(0, 0, NULL)

    try:
        _encode(writer, data)

        temp = ObjectRealloc(writer.obj, sizeof(PyASCIIObject) + writer.position + 1)
        if temp is not NULL:
            writer.obj = <AsciiObject*> temp
        writer.obj.data[writer.position] = 0

        result = ObjectInit(<PyObject*> writer.obj, unicode)
        writer.obj = NULL

        (<PyASCIIObject*> <PyObject*> result).length = writer.position
        (<PyASCIIObject*> <PyObject*> result).hash = -1
        (<PyASCIIObject*> <PyObject*> result).wstr = NULL
        (<PyASCIIObject*> <PyObject*> result).state.interned = SSTATE_NOT_INTERNED
        (<PyASCIIObject*> <PyObject*> result).state.kind = PyUnicode_1BYTE_KIND
        (<PyASCIIObject*> <PyObject*> result).state.compact = True
        (<PyASCIIObject*> <PyObject*> result).state.ready = True
        (<PyASCIIObject*> <PyObject*> result).state.ascii = True

        return result
    finally:
        if writer.obj is not NULL:
            ObjectFree(writer.obj)


def encode_bytes(data):
    cdef WriterVector writer
    _encode(writer, data)
    return PyBytes_FromStringAndSize(writer.buf.data(), writer.buf.size())


def encode_buffer(data):
    cdef WriterVector writer
    cdef EncodedMemoryView result = EncodedMemoryView()

    _encode(writer, data)

    swap(result.buf, writer.buf)
    result.buf.shrink_to_fit()
    result.length = result.buf.size()

    return memoryview(result)


def encode_bytearray(data):
    cdef WriterVector writer
    _encode(writer, data)
    return PyByteArray_FromStringAndSize(writer.buf.data(), writer.buf.size())


def encode_callback(data, object cb):
    cdef WriterCallback writer = WriterCallback(<PyObject*> cb)
    _encode(writer, data)


__all__ = (
    'decode', 'decode_latin1', 'decode_buffer', 'decode_iter',
    'encode', 'encode_bytes', 'encode_buffer', 'encode_callback',
)

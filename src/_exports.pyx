DEFAULT_MAX_NESTING_LEVEL = 32
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


def decode_callback(object callback, object max_depth=None, boolean some=False):
    if max_depth is None:
        max_depth = DEFAULT_MAX_NESTING_LEVEL

    if not callable(callback):
        raise TypeError('callback must be callable')

    return _decode_callable(<PyObject*> callback, max_depth, some)


def encode(data):
    cdef void *temp = NULL
    cdef object result
    cdef Py_ssize_t start = <Py_ssize_t> <void*> &(<AsciiObject*> 0).data[0]
    cdef Py_ssize_t length
    cdef WriterReallocatable writer = WriterReallocatable(
        Writer(_WriterReallocatable_reserve, _WriterReallocatable_append_c, _WriterReallocatable_append_s),
        start, 0, NULL,
    )

    try:
        _encode(writer.base, data)

        length = writer.position - start
        if length <= 0:
            # impossible
            return u''

        temp = ObjectRealloc(writer.obj, writer.position + 1)
        if temp is not NULL:
            writer.obj = temp
        (<char*> writer.obj)[writer.position] = 0

        result = ObjectInit(<PyObject*> writer.obj, unicode)
        writer.obj = NULL

        (<PyASCIIObject*> <PyObject*> result).length = length
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
    cdef void *temp = NULL
    cdef object result
    cdef Py_ssize_t start = <Py_ssize_t> <void*> &(<PyBytesObject*> 0).ob_sval[0]
    cdef Py_ssize_t length
    cdef WriterReallocatable writer = WriterReallocatable(
        Writer(_WriterReallocatable_reserve, _WriterReallocatable_append_c, _WriterReallocatable_append_s),
        start, 0, NULL,
    )

    try:
        _encode(writer.base, data)

        length = writer.position - start
        if length <= 0:
            # impossible
            return b''

        temp = ObjectRealloc(writer.obj, writer.position + 1)
        if temp is not NULL:
            writer.obj = temp
        (<char*> writer.obj)[writer.position] = 0

        result = <object> <PyObject*> ObjectInitVar((<PyVarObject*> writer.obj), bytes, length)
        writer.obj = NULL

        (<PyBytesObject*> writer.obj).ob_shash = -1

        return result
    finally:
        if writer.obj is not NULL:
            ObjectFree(writer.obj)


def encode_callback(data, object cb):
    cdef WriterCallback writer = WriterCallback(
        Writer(_WriterCallback_reserve, _WriterCallback_append_c, _WriterCallback_append_s),
        <PyObject*> cb,
    )
    _encode(writer.base, data)


__all__ = (
    'decode', 'decode_latin1', 'decode_buffer', 'decode_iter',
    'encode', 'encode_bytes', 'encode_callback',
)

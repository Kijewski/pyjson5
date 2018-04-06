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
    return _encode_to_unicode(data)


def encode_bytes(data):
    cdef WriterVector writer
    _encode(writer, data)
    return PyBytes_FromStringAndSize(writer.buf.data(), writer.buf.size())


__all__ = (
    'DEFAULT_MAX_NESTING_LEVEL', 'UNLIMITED',
    'decode', 'decode_latin1', 'decode_buffer', 'decode_iter',
    'encode', 'encode_bytes',
)

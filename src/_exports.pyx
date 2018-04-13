DEFAULT_MAX_NESTING_LEVEL = 32
TO_JSON = None


def decode(object data, object maxdepth=None, object some=False):
    '''
    Decodes JSON5 serialized data.

    Parameters
    ----------
    data : unicode
        JSON5 serialized data
    maxdepth : Optional[int] = None
        Maximum nesting level before are the parsing is aborted.

        If ``None`` is supplied, then the value of the global variable
        ``DEFAULT_MAX_NESTING_LEVEL`` is used instead.

        If the value is null, then only literals are accepted, e.g. ``false``,
        ``47.11``, or ``"string"``.

        If the value is negative, then the any nesting level is allowed until
        Python's recursion limit is hit.
    some : boolean = False
        Allow trailing junk.

    Returns
    -------
    object
        Deserialized data.
    '''
    if maxdepth is None:
        maxdepth = DEFAULT_MAX_NESTING_LEVEL

    if isinstance(data, unicode):
        return _decode_unicode(data, maxdepth, bool(some))
    else:
        raise TypeError(f'type(data) == {type(data)!r} not supported')


def decode_latin1(object data, object maxdepth=None, object some=False):
    '''
    Decodes JSON5 serialized data.

    Parameters
    ----------
    data : bytes
        JSON5 serialized data, encoded as Latin-1 or ASCII.
    maxdepth : Optional[int] = None
        see ``decode(...)`` 
    some : boolean = False
        see ``decode(...)`` 

    Returns
    -------
    object
        see ``decode(...)`` 
    '''
    return decode_buffer(data, maxdepth, bool(some), 1)


def decode_buffer(object obj, object maxdepth=None, object some=False,
                  object wordlength=None):
    '''
    Decodes JSON5 serialized data.

    Parameters
    ----------
    data : object
        JSON5 serialized data.
        The argument must support Python's buffer protocol, i.e.
        ``memoryview(...)`` must work. The buffer must be contigious.
    maxdepth : Optional[int] = None
        see ``decode(...)`` 
    some : boolean = False
        see ``decode(...)`` 
    wordlength : Optional[int] = None
        Must be 1, 2, 4 to denote UCS1, USC2 or USC4 data.
        Surrogates are not supported. Decode the data to an ``str`` if need be.
        If ``None`` is supplied, then the buffers ``itemsize`` is used.

    Returns
    -------
    object
        see ``decode(...)`` 
    '''
    cdef Py_buffer view

    if maxdepth is None:
        maxdepth = DEFAULT_MAX_NESTING_LEVEL

    PyObject_GetBuffer(obj, &view, PyBUF_CONTIG_RO)
    try:
        if wordlength is None:
            wordlength = view.itemsize
        return _decode_buffer(view, wordlength, maxdepth, bool(some))
    finally:
        PyBuffer_Release(&view)


def decode_callback(object cb, object maxdepth=None, object some=False,
                    object *args):
    '''
    Decodes JSON5 serialized data.

    Parameters
    ----------
    cb : Callable[Tuple[...], Union[bytes|str|int|None]]
        A function to get values from.
        The functions is called like ``cb(*args)``.

        Returns:
         * str, bytes, bytearray:
            ``len(...) == 0`` denotes exhausted input.
            ``len(...) == 1`` is the next character.
         * int:
            ``< 0`` denotes exhausted input.
            ``>= 0`` is the ordinal value of the next character.
    maxdepth : Optional[int] = None
        see ``decode(...)`` 
    some : boolean = False
        see ``decode(...)`` 
    *args : Tuple[...]
        Arguments to call ``cb`` with.

    Returns
    -------
    object
        see ``decode(...)`` 
    '''
    '''TODO''' # TODO


def loads(s, *, encoding='UTF-8', **kw):
    '''
    Decodes JSON5 serialized data.
    Use ``decode(...)`` instead!

    Parameters
    ----------
    s : object
        Unless the argument is an ``str``, it gets decoded according to the
        parameter ``encoding``.
    encoding : str = 'UTF-8'
        Codec to use if ``s`` is not an ``str``.
    **kw
        Silently ignored.

    Returns
    -------
    object
        see ``decode(...)`` 
    '''
    if not isinstance(s, unicode):
        s = unicode(s, encoding, 'strict')
    return decode(s)


def encode(object data):
    '''
    Serializes a Python object to a JSON5 compatible string.

    Parameters
    ----------
    data : object
        Python object to serialize.

    Returns
    -------
    unicode
        Unless ``float('inf')`` or ``float('nan')`` is encountered, the result
        will be valid JSON data (as of RFC8259).

        The result is always ASCII. All characters outside of the ASCII range
        are encoded.

        The result safe to use in an HTML template, e.g.
        ``<a onclick='alert({{ encode(url) }})'>show message</a>`.
        Apostrophes ``"'"`` are encoded as ``r"\u0027"``, less-than,
        greater-than, and ampersand likewise.
    '''
    cdef void *temp = NULL
    cdef object result
    cdef Py_ssize_t start = (
        <Py_ssize_t> <void*> &(<AsciiObject*> NULL).data[0]
    )
    cdef Py_ssize_t length
    cdef WriterReallocatable writer = WriterReallocatable(
        Writer(
            _WriterReallocatable_reserve,
            _WriterReallocatable_append_c,
            _WriterReallocatable_append_s,
        ),
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

        (<PyASCIIObject*> result).length = length
        (<PyASCIIObject*> result).hash = -1
        (<PyASCIIObject*> result).wstr = NULL
        (<PyASCIIObject*> result).state.interned = SSTATE_NOT_INTERNED
        (<PyASCIIObject*> result).state.kind = PyUnicode_1BYTE_KIND
        (<PyASCIIObject*> result).state.compact = True
        (<PyASCIIObject*> result).state.ready = True
        (<PyASCIIObject*> result).state.ascii = True

        return result
    finally:
        if writer.obj is not NULL:
            ObjectFree(writer.obj)


def encode_bytes(object data):
    '''
    Serializes a Python object to a JSON5 compatible string.

    Parameters
    ----------
    data : object
        see ``encode(data)``

    Returns
    -------
    bytes
        see ``encode(data)``
    '''
    cdef void *temp = NULL
    cdef object result
    cdef Py_ssize_t start = (
        <Py_ssize_t> <void*> &(<PyBytesObject*> NULL).ob_sval[0]
    )
    cdef Py_ssize_t length
    cdef WriterReallocatable writer = WriterReallocatable(
        Writer(
            _WriterReallocatable_reserve,
            _WriterReallocatable_append_c,
            _WriterReallocatable_append_s,
        ),
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

        result = <object> <PyObject*> ObjectInitVar(
            (<PyVarObject*> writer.obj), bytes, length,
        )
        writer.obj = NULL

        (<PyBytesObject*> result).ob_shash = -1

        return result
    finally:
        if writer.obj is not NULL:
            ObjectFree(writer.obj)


def encode_callback(object data, object cb, object supply_bytes=False):
    '''
    Serializes a Python object to a JSON5 compatible string.

    The callback function ``cb`` gets called with single characters and strings
    until the input ``data`` is fully serialized.

    Parameters
    ----------
    data : object
        see ``encode(data)``
    cb : Callable[Any, None]
        A callback function.
        Depending on the truthyness of ``supply_bytes`` either ``bytes`` or
        ``str`` is supplied.
    supply_bytes : boolean = True
        Call ``cb(...)`` with a ``bytes`` argument if true,
        otherwise ``str``.

    Returns
    -------
    Callable[Any, None]
        The supplied argument ``cb``.
    '''
    cdef boolean (*encoder)(object obj, object cb) except False

    if supply_bytes:
        encoder = _encode_callback_bytes
    else:
        encoder = _encode_callback_str

    encoder(data, cb)

    return cb


def encode_io(object data, object fp, object supply_bytes=True):
    '''
    Serializes a Python object to a JSON5 compatible string.

    The return value of ``fp.write(...)`` is not checked.
    If ``fp`` is unbuffered, then the result will be garbage!

    Parameters
    ----------
    data : object
        see ``encode(data)``
    fp : IOBase
        A file-like object to serialize into.
    supply_bytes : boolean = True
        Call ``fp.write(...)`` with a ``bytes`` argument if true,
        otherwise ``str``.

    Returns
    -------
    IOBase
        The supplied argument ``fp``.
    '''
    cdef boolean (*encoder)(object obj, object cb) except False

    if not isinstance(fp, IOBase):
        raise TypeError(f'type(fp)=={type(fp)!r} is not IOBase compatible')
    elif not fp.writable():
        raise TypeError(f'fp is not writable')
    elif fp.closed:
        raise TypeError(f'fp is closed')

    if supply_bytes:
        encoder = _encode_callback_bytes
    else:
        encoder = _encode_callback_str

    encoder(data, fp.write)

    return fp


def encode_noop(object data):
    '''
    Test if the input is serializable.

    Most likely you want to serialize ``data`` directly, and catch exceptions
    instead of using this function.

    Parameters
    ----------
    data : object
        see ``encode(data)``

    Returns
    -------
    bool
        ``True`` iff ``data`` is serializable.
    '''
    cdef Writer writer = Writer(
        _WriterNoop_reserve,
        _WriterNoop_append_c,
        _WriterNoop_append_s,
    )

    try:
        _encode(writer, data)
    except Exception:
        return False

    return True


def dumps(obj, **kw):
    '''
    Serializes a Python object to a JSON5 compatible string.
    Use ``encode(obj)`` instead!

    Parameters
    ----------
    obj : object
        Python object to serialize.
    **kw
        Silently ignored.

    Returns
    -------
    unicode
        see ``encode(data)``
    '''
    return encode(obj)


__all__ = (
    'decode', 'decode_latin1', 'decode_buffer', 'decode_callback',
    'encode', 'encode_bytes', 'encode_callback', 'encode_io', 'encode_noop',
    'loads', 'load', 'dumps', 'dump',
)

__doc__ = '''\
A JSON5 serializer and parser library for Python 3 written in Cython.

The serializer returns ASCII data that can safely be used in an HTML template.
Apostrophes, ampersands, greater-than, and less-then signs are encoded as
unicode escaped sequences. E.g. this snippet is safe for any and all input:

    "<a onclick='alert(" + encode(data) + ")'>show message</a>"

Unless the input contains infinite or NaN values, the result will be valid
JSON data.

All valid JSON5 1.0.0 and JSON data can be read, unless the nesting level is
absurdly high.
'''

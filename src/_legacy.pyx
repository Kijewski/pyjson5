def loads(s, *, encoding='UTF-8', **kw):
    '''
    Decodes JSON5 serialized data from a string.

    Use `decode(...) <pyjson5.decode_>`_ instead!

    .. code:: python

        loads(s) == decode(s)

    Parameters
    ----------
    s : object
        Unless the argument is an ``str``, it gets decoded according to the
        parameter ``encoding``.
    encoding : str
        Codec to use if ``s`` is not an ``str``.
    kw
        Silently ignored.

    Returns
    -------
    object
        see ``decode(...)``
    '''
    if not isinstance(s, unicode):
        s = PyUnicode_FromEncodedObject(s, encoding, 'strict')
    return decode(s)


def load(fp, **kw):
    '''
    Decodes JSON5 serialized data from a file-like object.

    Use `decode_io(...) <pyjson5.decode_io_>`_ instead!

    .. code:: python

        load(fp) == decode_io(fp, None, False)

    Parameters
    ----------
    fp : IOBase
        A file-like object to parse from.
    kw
        Silently ignored.

    Returns
    -------
    object
        see ``decode(...)``
    '''
    return decode_io(fp, None, False)


def dumps(obj, **kw):
    '''
    Serializes a Python object to a JSON5 compatible unicode string.

    Use `encode(...) <pyjson5.encode_>`_ instead!

    .. code:: python

        dumps(obj) == encode(obj)

    Parameters
    ----------
    obj : object
        Python object to serialize.
    kw
        Silently ignored.

    Returns
    -------
    unicode
        see ``encode(data)``
    '''
    return encode(obj)


def dump(object obj, object fp, **kw):
    '''
    Serializes a Python object to a JSON5 compatible unicode string.

    Use `encode_io(...) <pyjson5.encode_io_>`_ instead!

    .. code:: python

        dump(obj, fp) == encode_io(obj, fp)

    Parameters
    ----------
    obj : object
        Python object to serialize.
    fp : IOBase
        A file-like object to serialize into.
    kw
        Silently ignored.
    '''
    encode_io(obj, fp)

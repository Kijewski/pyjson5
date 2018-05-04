cdef enum EncType:
    ENC_TYPE_EXCEPTION
    ENC_TYPE_UNKNOWN
    ENC_TYPE_NONE
    ENC_TYPE_UNICODE
    ENC_TYPE_BOOL
    ENC_TYPE_BYTES
    ENC_TYPE_LONG
    ENC_TYPE_DECIMAL
    ENC_TYPE_FLOAT
    ENC_TYPE_DATETIME
    ENC_TYPE_MAPPING
    ENC_TYPE_SEQUENCE


cdef boolean _encode_unicode_impl(WriterRef writer, UCSString data, Py_ssize_t length) except False:
    cdef char buf[32]
    cdef uint32_t c
    cdef uint32_t s1, s2
    cdef const char *escaped_string
    cdef Py_ssize_t escaped_length
    cdef size_t unescaped_length, index
    cdef Py_ssize_t sublength

    if length > 0:
        writer.reserve(writer, 2 + length)
        writer.append_c(writer, <char> b'"')
        while True:
            if UCSString is UCS1String:
                sublength = length
            else:
                sublength = min(length, <Py_ssize_t> sizeof(buf))

            unescaped_length = ESCAPE_DCT.find_unescaped_range(data, sublength)
            if unescaped_length > 0:
                if UCSString is UCS1String:
                    writer.append_s(writer, <const char*> data, unescaped_length)
                else:
                    for index in range(unescaped_length):
                        buf[index] = <const char> data[index]
                    writer.append_s(writer, buf, unescaped_length)

                data += unescaped_length
                length -= unescaped_length
                if length <= 0:
                    break

                if UCSString is not UCS1String:
                    continue

            c = data[0]
            if (UCSString is UCS1String) or (c < 0x100):
                escaped_string = &ESCAPE_DCT.items[c][0]
                escaped_length = ESCAPE_DCT.items[c][7]
                writer.append_s(writer, escaped_string, escaped_length)
            elif (UCSString is UCS2String) or (c <= 0xffff):
                buf[0] = '\\';
                buf[1] = 'u';
                buf[2] = HEX[(c >> (4*3)) & 0xf];
                buf[3] = HEX[(c >> (4*2)) & 0xf];
                buf[4] = HEX[(c >> (4*1)) & 0xf];
                buf[5] = HEX[(c >> (4*0)) & 0xf];
                buf[6] = 0;

                writer.append_s(writer, buf, 6);
            else:
                # surrogate pair
                c -= 0x10000
                s1 = 0xd800 | ((c >> 10) & 0x3ff)
                s2 = 0xdc00 | (c & 0x3ff)

                buf[0x0] = '\\';
                buf[0x1] = 'u';
                buf[0x2] = HEX[(s1 >> (4*3)) & 0xf];
                buf[0x3] = HEX[(s1 >> (4*2)) & 0xf];
                buf[0x4] = HEX[(s1 >> (4*1)) & 0xf];
                buf[0x5] = HEX[(s1 >> (4*0)) & 0xf];

                buf[0x6] = '\\';
                buf[0x7] = 'u';
                buf[0x8] = HEX[(s2 >> (4*3)) & 0xf];
                buf[0x9] = HEX[(s2 >> (4*2)) & 0xf];
                buf[0xa] = HEX[(s2 >> (4*1)) & 0xf];
                buf[0xb] = HEX[(s2 >> (4*0)) & 0xf];

                buf[0xc] = 0;

                writer.append_s(writer, buf, 12);

            data += 1
            length -= 1
            if length <= 0:
                break
        writer.append_c(writer, <char> b'"')
    else:
        writer.append_s(writer, b'""', 2)

    return True


cdef boolean _encode_unicode(WriterRef writer, object data, EncType enc_type) except False:
    cdef Py_ssize_t length
    cdef int kind

    PyUnicode_READY(data)

    length = PyUnicode_GET_LENGTH(data)
    kind = PyUnicode_KIND(data)

    if kind == PyUnicode_1BYTE_KIND:
        _encode_unicode_impl(writer, PyUnicode_1BYTE_DATA(data), length)
    elif kind == PyUnicode_2BYTE_KIND:
        _encode_unicode_impl(writer, PyUnicode_2BYTE_DATA(data), length)
    elif kind == PyUnicode_4BYTE_KIND:
        _encode_unicode_impl(writer, PyUnicode_4BYTE_DATA(data), length)
    else:
        pass  # impossible

    return True


cdef boolean _encode_nested_key(WriterRef writer, object data) except False:
    cdef const char *string
    cdef char c
    cdef Py_ssize_t index, length

    cdef WriterReallocatable sub_writer = WriterReallocatable(
        Writer(
            _WriterReallocatable_reserve,
            _WriterReallocatable_append_c,
            _WriterReallocatable_append_s,
            writer.options,
        ),
        0, 0, NULL,
    )
    try:
        _encode(sub_writer.base, data)

        length = sub_writer.position
        string = <char*> sub_writer.obj

        writer.reserve(writer, 2 + length)
        writer.append_c(writer, <char> b'"')
        for index in range(length):
            c = string[index]
            if c not in b'\\"':
                writer.append_c(writer, c)
            elif c == b'\\':
                writer.append_s(writer, b'\\\\', 2)
            else:
                writer.append_s(writer, b'\\u0022', 6)
        writer.append_c(writer, <char> b'"')
    finally:
        if sub_writer.obj is not NULL:
            ObjectFree(sub_writer.obj)

    return True


cdef boolean _append_ascii(WriterRef writer, object data) except False:
    cdef Py_buffer view
    cdef const char *buf

    if PyUnicode_Check(data):
        PyUnicode_READY(data)
        if not PyUnicode_IS_ASCII(data):
            raise TypeError('Expected ASCII data')
        writer.append_s(writer, <const char*> PyUnicode_1BYTE_DATA(data), PyUnicode_GET_LENGTH(data))
    else:
        PyObject_GetBuffer(data, &view, PyBUF_CONTIG_RO)
        try:
            buf = <const char*> view.buf
            for index in range(view.len):
                c = buf[index]
                if c & ~0x7f:
                    raise TypeError('Expected ASCII data')

            writer.append_s(writer, buf, view.len)
        finally:
            PyBuffer_Release(&view)

    return True


cdef boolean _encode_sequence(WriterRef writer, object data) except False:
    cdef boolean first
    cdef object value

    writer.append_c(writer, <char> b'[')
    first = True
    for value in data:
        if not first:
            writer.append_c(writer, <char> b',')
        else:
            first = False
        _encode(writer, value)
    writer.append_c(writer, <char> b']')

    return True


cdef boolean _encode_mapping(WriterRef writer, object data) except False:
    cdef boolean first
    cdef object key, value

    writer.append_c(writer, <char> b'{')
    first = True
    for key in data:
        if not first:
            writer.append_c(writer, <char> b',')
        else:
            first = False
        value = data[key]

        if PyUnicode_Check(key):
            _encode_unicode(writer, key, ENC_TYPE_UNICODE)
        else:
            _encode_nested_key(writer, key)

        writer.append_c(writer, <char> b':')
        _encode(writer, value)
    writer.append_c(writer, <char> b'}')

    return True


cdef boolean _encode_constant(WriterRef writer, object data, EncType enc_type) except False:
    cdef const char *string
    cdef Py_ssize_t length
    
    if data is True:
        string = b'true'
        length = 4
    elif data is False:
        string = b'false'
        length = 5
    else:
        string = b'null'
        length = 4

    writer.append_s(writer, string, length)
    return True


cdef boolean _encode_bytes(WriterRef writer, object data, EncType enc_type) except False:
    cdef unicode_data = data.decode('UTF-8', 'replace')
    _encode_unicode(writer, unicode_data, ENC_TYPE_UNICODE)
    return True


cdef boolean _encode_datetime(WriterRef writer, object data, EncType enc_type) except False:
    cdef const char *string
    cdef Py_ssize_t length
    cdef object stringified

    stringified = data.isoformat()
    string = PyUnicode_AsUTF8AndSize(stringified, &length)

    writer.reserve(writer, 2 + length)
    writer.append_c(writer, <char> b'"')
    writer.append_s(writer, string, length)
    writer.append_c(writer, <char> b'"')

    return True


cdef boolean _encode_numeric(WriterRef writer, object data, EncType enc_type) except False:
    cdef object formatter_string
    cdef const char *string
    cdef Py_ssize_t length
    cdef int classification

    if enc_type == ENC_TYPE_LONG:
        formatter_string = (<Options> writer.options).intformat
    elif enc_type == ENC_TYPE_DECIMAL:
        formatter_string = (<Options> writer.options).decimalformat
    else:
        value = PyFloat_AsDouble(data)
        classification = fpclassify(value)
        if classification == FP_NORMAL:
            formatter_string = (<Options> writer.options).floatformat
        elif classification in (FP_SUBNORMAL, FP_ZERO):
            string = b'0'
            length = 1

            writer.append_s(writer, string, length)
            return True
        else:
            if classification == FP_NAN:
                formatter_string = (<Options> writer.options).nan
            elif value > 0.0:
                formatter_string = (<Options> writer.options).posinfinity
            else:
                formatter_string = (<Options> writer.options).neginfinity

            if formatter_string is None:
                _raise_unstringifiable(data)

            string = <const char*> PyUnicode_1BYTE_DATA(formatter_string)
            length = PyUnicode_GET_LENGTH(formatter_string)

            writer.append_s(writer, string, length)
            return True

    if formatter_string is None:
        _raise_unstringifiable(data)

    formatter_string = (formatter_string % data)
    string = PyUnicode_AsUTF8AndSize(formatter_string, &length)
    writer.append_s(writer, string, length)
    return True


cdef boolean _encode_recursive(WriterRef writer, object data, EncType enc_type) except False:
    cdef object to_json
    cdef boolean (*encoder)(WriterRef writer, object data) except False

    Py_EnterRecursiveCall(' while encoding nested JSON5 object')
    try:
        to_json = (<Options> writer.options).tojson
        if to_json is not None:
            to_json = getattr(data, to_json, None)
            if to_json is not None:
                if callable(to_json):
                    to_json = to_json()
                _append_ascii(writer, to_json)
                return True

        if enc_type == ENC_TYPE_SEQUENCE:
            encoder = _encode_sequence
        elif enc_type == ENC_TYPE_MAPPING:
            encoder = _encode_mapping
        else:
            _raise_unstringifiable(data)
            encoder = NULL

        encoder(writer, data)
        return True
    finally:
        Py_LeaveRecursiveCall()


cdef boolean _encode(WriterRef writer, object data) except False:
    cdef boolean (*encoder)(WriterRef, object, EncType) except False
    cdef EncType enc_type

    if data is None:
        enc_type = ENC_TYPE_NONE
    elif PyUnicode_Check(data):
        enc_type = ENC_TYPE_UNICODE
    elif PyBool_Check(data):
        enc_type = ENC_TYPE_BOOL
    elif PyBytes_Check(data):
        enc_type = ENC_TYPE_BYTES
    elif PyLong_Check(data):
        enc_type = ENC_TYPE_LONG
    elif PyFloat_Check(data):
        enc_type = ENC_TYPE_FLOAT
    elif obj_has_iter(data):
        if isinstance(data, (<Options> writer.options).mappingtypes):
            enc_type = ENC_TYPE_MAPPING
        else:
            enc_type = ENC_TYPE_SEQUENCE
    elif isinstance(data, Decimal):
        enc_type = ENC_TYPE_DECIMAL
    elif isinstance(data, DATETIME_CLASSES):
        enc_type = ENC_TYPE_DATETIME
    elif data == None:
        enc_type = ENC_TYPE_NONE
    else:
        enc_type = ENC_TYPE_UNKNOWN

    encoder = _encode_recursive
    if enc_type in (ENC_TYPE_NONE, ENC_TYPE_BOOL):
        encoder = _encode_constant
    elif enc_type == ENC_TYPE_UNICODE:
        encoder = _encode_unicode
    elif enc_type == ENC_TYPE_BYTES:
        encoder = _encode_bytes
    elif enc_type in (ENC_TYPE_LONG, ENC_TYPE_DECIMAL, ENC_TYPE_FLOAT):
        encoder = _encode_numeric
    elif enc_type == ENC_TYPE_DATETIME:
        encoder = _encode_datetime

    encoder(writer, data, enc_type)

    return True


cdef boolean _encode_callback_bytes(object data, object cb, object options) except False:
    cdef WriterCallback writer = WriterCallback(
        Writer(
            _WriterNoop_reserve,
            _WriterCbBytes_append_c,
            _WriterCbBytes_append_s,
            <PyObject*> options,
        ),
        <PyObject*> cb,
    )

    if not callable(cb):
        raise TypeError(f'type(cb)=={type(cb)!r} is callable')

    _encode(writer.base, data)

    return True


cdef boolean _encode_callback_str(object data, object cb, object options) except False:
    cdef WriterCallback writer = WriterCallback(
        Writer(
            _WriterNoop_reserve,
            _WriterCbStr_append_c,
            _WriterCbStr_append_s,
            <PyObject*> options,
        ),
        <PyObject*> cb,
    )

    if not callable(cb):
        raise TypeError(f'type(cb)=={type(cb)!r} is callable')

    _encode(writer.base, data)

    return True

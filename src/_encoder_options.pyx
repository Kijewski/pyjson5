cdef object DEFAULT_TOJSON = False
cdef object DEFAULT_POSINFINITY = 'Infinity'
cdef object DEFAULT_NEGINFINITY = '-Infinity'
cdef object DEFAULT_NAN = 'NaN'
cdef object DEFAULT_INTFORMAT = '%d'
cdef object DEFAULT_FLOATFORMAT = '%.6e'
cdef object DEFAULT_DECIMALFORMAT = '%s'
cdef object DEFAULT_MAPPINGTYPES = (Mapping,)
cdef object DEFAULT_QUOTATIONMARK = '"'


cdef object _options_ascii(object datum, boolean expect_ascii=True):
    if datum is False:
        return None
    elif PyBytes_Check(datum):
        datum = unicode(datum, 'UTF-8', 'strict')
    elif not PyUnicode_Check(datum):
        raise TypeError('Expected str instance or False')

    PyUnicode_READY(datum)
    if expect_ascii and not PyUnicode_IS_ASCII(datum):
        raise ValueError('Expected ASCII data')

    return datum


cdef object _options_reduce_arg(object key, object value, object default):
    if value != default:
        if value is not None:
            return key, value
        else:
            return key, False


cdef object _option_from_ascii(object name, object value, object default):
    if value == default:
        return
    elif value is None:
        return f'{name}=False'
    else:
        return f'{name}={value!r}'


cdef _options_from_ascii(Options self):
    return ', '.join(filter(bool, (
        _option_from_ascii('quotationmark', self.quotationmark, DEFAULT_QUOTATIONMARK),
        _option_from_ascii('tojson', self.tojson, None),
        _option_from_ascii('posinfinity', self.posinfinity, DEFAULT_POSINFINITY),
        _option_from_ascii('neginfinity', self.neginfinity, DEFAULT_NEGINFINITY),
        _option_from_ascii('intformat', self.intformat, DEFAULT_INTFORMAT),
        _option_from_ascii('floatformat', self.floatformat, DEFAULT_FLOATFORMAT),
        _option_from_ascii('decimalformat', self.decimalformat, DEFAULT_DECIMALFORMAT),
        _option_from_ascii('nan', self.nan, DEFAULT_NAN),
    )))


@final
@no_gc
@freelist(8)
@auto_pickle(False)
cdef class Options:
    '''
    Customizations for the ``encoder_*(...)`` function family.

    Immutable. Use ``Options.update(**kw)`` to create a **new** Options instance.

    Parameters
    ----------
    quotationmark : str|None
        * **str**: One character string that is used to surround strings.
        * **None**: Use default: ``'"'``.
    tojson : str|False|None
        * **str:** A special method to call on objects to return a custom JSON encoded string. Must return ASCII data!
        * **False:** No such member exists. (Default.)
        * **None:** Use default.
    posinfinity : str|False|None
        * **str:** String to represent positive infinity. Must be ASCII.
        * **False:** Throw an exception if ``float('+inf')`` is encountered.
        * **None:** Use default: ``"Infinity"``.
    neginfinity : str|False|None
        * **str:** String to represent negative infinity. Must be ASCII.
        * **False:** Throw an exception if ``float('-inf')`` is encountered.
        * **None:** Use default: ``"-Infinity"``.
    nan : str|False|None
        * **str:** String to represent not-a-number. Must be ASCII.
        * **False:** Throw an exception if ``float('NaN')`` is encountered.
        * **None:** Use default: ``"NaN"``.
    intformat : str|False|None
        * **str:** Format string to use with ``int``.
        * **False:** Throw an exception if an ``int`` is encountered.
        * **None:** Use default: ``"%d"``.
    floatformat : str|False|None
        * **str:** Format string to use with ``float``.
        * **False:** Throw an exception if a ``float`` is encountered.
        * **None:** Use default: ``"%.6e"``.
    decimalformat : str|False|None
        * **str:** Format string to use with ``Decimal``.
        * **False:** Throw an exception if a ``Decimal`` is encountered.
        * **None:** Use default: ``"%s"``.
    mappingtypes : Iterable[type]|False|None
        * **Iterable[type]:** Classes that should be encoded to objects. Must be iterable over their keys, and implement ``__getitem__``.
        * **False:** There are no objects. Any object will be encoded as list of keys as in list(obj).
        * **None:** Use default: ``[collections.abc.Mapping]``.
    '''
    cdef readonly unicode quotationmark
    '''The creation argument ``quotationmark``.
    '''
    cdef readonly unicode tojson
    '''The creation argument ``tojson``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly unicode posinfinity
    '''The creation argument ``posinfinity``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly unicode neginfinity
    '''The creation argument ``neginfinity``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly unicode nan
    '''The creation argument ``nan``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly unicode intformat
    '''The creation argument ``intformat``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly unicode floatformat
    '''The creation argument ``floatformat``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly unicode decimalformat
    '''The creation argument ``decimalformat``.
    ``None`` if ``False`` was specified.
    '''
    cdef readonly tuple mappingtypes
    '''The creation argument ``mappingtypes``.
    ``()`` if ``False`` was specified.
    '''

    def __reduce__(self):
        cdef object args = tuple(filter(bool, (
            _options_reduce_arg('quotationmark', self.quotationmark, DEFAULT_QUOTATIONMARK),
            _options_reduce_arg('tojson', self.tojson, None),
            _options_reduce_arg('posinfinity', self.posinfinity, DEFAULT_POSINFINITY),
            _options_reduce_arg('neginfinity', self.neginfinity, DEFAULT_NEGINFINITY),
            _options_reduce_arg('intformat', self.intformat, DEFAULT_INTFORMAT),
            _options_reduce_arg('floatformat', self.floatformat, DEFAULT_FLOATFORMAT),
            _options_reduce_arg('decimalformat', self.decimalformat, DEFAULT_DECIMALFORMAT),
            _options_reduce_arg('nan', self.nan, DEFAULT_NAN),
        )))
        return (_UnpickleOptions if args else Options), args

    def __repr__(self):
        cdef object repr_options = _options_from_ascii(self)
        cdef object repr_cls = (
            ''
            if self.mappingtypes == DEFAULT_MAPPINGTYPES else
            repr(DEFAULT_MAPPINGTYPES)
        )
        return (f'Options('
            f'{repr_options}'
            f'{repr_options and repr_cls and ", "}'
            f'{repr_cls}'
        ')')

    def __str__(self):
        return self.__repr__()

    def __cinit__(self, *,
                  quotationmark=None,
                  tojson=None, posinfinity=None, neginfinity=None, nan=None,
                  decimalformat=None, intformat=None, floatformat=None,
                  mappingtypes=None):
        cdef object cls
        cdef object ex

        if quotationmark is None:
            quotationmark = DEFAULT_QUOTATIONMARK
        if tojson is None:
            tojson = DEFAULT_TOJSON
        if posinfinity is None:
            posinfinity = DEFAULT_POSINFINITY
        if neginfinity is None:
            neginfinity = DEFAULT_NEGINFINITY
        if nan is None:
            nan = DEFAULT_NAN
        if intformat is None:
            intformat = DEFAULT_INTFORMAT
        if floatformat is None:
            floatformat = DEFAULT_FLOATFORMAT
        if decimalformat is None:
            decimalformat = DEFAULT_DECIMALFORMAT
        if mappingtypes is None:
            mappingtypes = DEFAULT_MAPPINGTYPES

        self.quotationmark = _options_ascii(quotationmark)
        self.tojson = _options_ascii(tojson, False)
        self.posinfinity = _options_ascii(posinfinity)
        self.neginfinity = _options_ascii(neginfinity)
        self.intformat = _options_ascii(intformat)
        self.floatformat = _options_ascii(floatformat)
        self.decimalformat = _options_ascii(decimalformat)
        self.nan = _options_ascii(nan)

        if self.quotationmark is None or PyUnicode_GET_LENGTH(self.quotationmark) != 1:
            raise TypeError('quotationmark must be one ASCII character.')

        if intformat is not None:
            try:
                PyUnicode_Format(intformat, TEST_INT)
            except Exception as ex:
                raise ValueError('intformat is not a valid format string') from ex

        if floatformat is not None:
            try:
                PyUnicode_Format(floatformat, TEST_FLOAT)
            except Exception as ex:
                raise ValueError('floatformat is not a valid format string') from ex

        if decimalformat is not None:
            try:
                PyUnicode_Format(decimalformat, TEST_DECIMAL)
            except Exception as ex:
                raise ValueError('decimalformat is not a valid format string') from ex

        if mappingtypes is False:
            self.mappingtypes = ()
        else:
            self.mappingtypes = tuple(mappingtypes)
            for cls in self.mappingtypes:
                if not PyType_Check(cls):
                    raise TypeError('mappingtypes must be a sequence of types '
                                    'or False')

    def update(self, *args, **kw):
        '''
        Creates a new Options instance by modifying some members.
        '''
        if kw:
            return _to_options(self, kw)
        else:
            return self


cdef Options DEFAULT_OPTIONS_OBJECT = Options()


def _UnpickleOptions(*args):
    if args:
        return _to_options(None, dict(args))
    else:
        return DEFAULT_OPTIONS_OBJECT


cdef object _to_options(Options arg, dict kw):
    if arg is None:
        if not kw:
            return DEFAULT_OPTIONS_OBJECT
        else:
            return Options(**kw)
    elif not kw:
        return arg

    PyDict_SetDefault(kw, 'quotationmark', (<Options> arg).quotationmark)
    PyDict_SetDefault(kw, 'tojson', (<Options> arg).tojson)
    PyDict_SetDefault(kw, 'posinfinity', (<Options> arg).posinfinity)
    PyDict_SetDefault(kw, 'neginfinity', (<Options> arg).neginfinity)
    PyDict_SetDefault(kw, 'nan', (<Options> arg).nan)
    PyDict_SetDefault(kw, 'intformat', (<Options> arg).intformat)
    PyDict_SetDefault(kw, 'floatformat', (<Options> arg).floatformat)
    PyDict_SetDefault(kw, 'decimalformat', (<Options> arg).decimalformat)
    PyDict_SetDefault(kw, 'mappingtypes', (<Options> arg).mappingtypes)

    return Options(**kw)

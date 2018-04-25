cdef object CONST_POS_NAN = float('+NaN')
cdef object CONST_POS_INF = float('+Infinity')
cdef object CONST_NEG_NAN = float('-NaN')
cdef object CONST_NEG_INF = float('-Infinity')

cdef object DATETIME_CLASSES = (date, time, datetime,)
cdef object ORD_CLASSES = (unicode, bytes, bytearray,)

cdef object UCS1_COMPATIBLE_CODECS = frozenset((
    # ASCII
    'ascii', 646, '646', 'us-ascii',
    # Latin-1
    'latin_1', 'latin-1', 'iso-8859-1', 'iso8859-1',
    8859, '8859', 'cp819', 'latin', 'latin1', 'l1',
))

cdef class Json5EncoderException(Exception):
    pass


cdef class Json5ExtraData(Json5EncoderException):
    cdef public object read_datum
    cdef public object extra_character

    def __init__(self, object message=None, object read_datum=None, object extra_character=None):
        super().__init__(message, read_datum, extra_character)
        self.message = message
        self.read_datum = read_datum
        self.extra_character = extra_character


cdef class Json5IllegalCharacter(Json5EncoderException):
    pass


cdef class Json5EOF(Json5EncoderException):
    pass


cdef class Json5NestingTooDeep(Json5EncoderException):
    pass


cdef class Json5UnframedData(Json5ExtraData):
    pass

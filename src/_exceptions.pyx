cdef class Json5EncoderException(Exception):
    pass


cdef class Json5ExtraData(Json5EncoderException):
    pass


cdef class Json5IllegalCharacter(Json5EncoderException):
    pass


cdef class Json5EOF(Json5EncoderException):
    pass


cdef class Json5NestingTooDeep(Json5EncoderException):
    pass


cdef class Json5Todo(Json5EncoderException):
    pass

cdef class Json5EncoderException(Exception):
    pass


cdef class Json5ExtraData(Json5EncoderException):
    def __init__(self, object message=None, object result=None, object extra=None):
        super().__init__(message, result, extra)

    @property
    def message(self):
        return self.args[0]

    @property
    def result(self):
        return self.args[1]

    @property
    def extra(self):
        return self.args[2]


cdef class Json5IllegalCharacter(Json5EncoderException):
    pass


cdef class Json5EOF(Json5EncoderException):
    pass


cdef class Json5NestingTooDeep(Json5EncoderException):
    pass


cdef class Json5UnframedData(Json5ExtraData):
    pass


cdef class Json5UnstringifiableType(Json5EncoderException):
    def __init__(self, object message=None, object unstringifiable=None):
        super().__init__(message, unstringifiable)

    @property
    def message(self):
        return self.args[0]

    @property
    def unstringifiable(self):
        return self.args[1]

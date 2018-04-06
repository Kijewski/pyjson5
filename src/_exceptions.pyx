@auto_pickle(False)
cdef class Json5EncoderException(Exception):
    def __init__(self, message=None, *args):
        super().__init__(message, *args)

    @property
    def message(self):
        return self.args[0]


@final
@auto_pickle(False)
cdef class Json5ExtraData(Json5EncoderException):
    def __init__(self, message=None, result=None, extra=None):
        super().__init__(message, result, extra)

    @property
    def result(self):
        return self.args[1]

    @property
    def extra(self):
        return self.args[2]


@final
@auto_pickle(False)
cdef class Json5IllegalCharacter(Json5EncoderException):
    pass


@final
@auto_pickle(False)
cdef class Json5EOF(Json5EncoderException):
    pass


@final
@auto_pickle(False)
cdef class Json5NestingTooDeep(Json5EncoderException):
    pass


@final
@auto_pickle(False)
cdef class Json5UnstringifiableType(Json5EncoderException):
    def __init__(self, message=None, unstringifiable=None):
        super().__init__(message, unstringifiable)

    @property
    def unstringifiable(self):
        return self.args[1]

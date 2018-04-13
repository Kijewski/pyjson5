@auto_pickle(False)
cdef class Json5EncoderException(Json5Exception):
    '''
    Base class of any exception thrown by the serializer.
    '''


@auto_pickle(False)
cdef class Json5UnstringifiableType(Json5EncoderException):
    def __init__(self, message=None, unstringifiable=None):
        super().__init__(message, unstringifiable)

    @property
    def unstringifiable(self):
        return self.args[1]

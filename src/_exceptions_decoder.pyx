@auto_pickle(False)
cdef class Json5DecoderException(Json5Exception):
    '''
    Base class of any exception thrown by the parser.
    '''
    def __init__(self, message=None, result=None, *args):
        super().__init__(message, result, *args)

    @property
    def result(self):
        '''Deserialized data up until now.'''
        return self.args[1]


@final
@auto_pickle(False)
cdef class Json5NestingTooDeep(Json5DecoderException):
    pass


@final
@auto_pickle(False)
cdef class Json5EOF(Json5DecoderException):
    pass


@final
@auto_pickle(False)
cdef class Json5IllegalCharacter(Json5DecoderException):
    def __init__(self, message=None, result=None, character=None, *args):
        super().__init__(message, result, character, *args)

    @property
    def character(self):
        '''Extranous character.'''
        return self.args[2]


@final
@auto_pickle(False)
cdef class Json5ExtraData(Json5DecoderException):
    '''
    The input contained extranous data.
    '''
    def __init__(self, message=None, result=None, character=None, *args):
        super().__init__(message, result, character, *args)

    @property
    def character(self):
        '''Extranous character.'''
        return self.args[2]


@final
@auto_pickle(False)
cdef class Json5IllegalType(Json5DecoderException):
    def __init__(self, message=None, result=None, value=None, *args):
        super().__init__(message, result, value, *args)

    @property
    def value(self):
        return self.args[2]


class _DecoderException(BaseException):
    def __init__(self, cls, msg, extra, result):
        self.cls = cls
        self.msg = msg
        self.extra = extra
        self.result = result

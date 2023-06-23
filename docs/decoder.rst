Parser / Decoder
================

All valid `JSON5 1.0.0 <https://spec.json5.org/>`_ and
`JSON <https://tools.ietf.org/html/rfc8259>`_ data can be read,
unless the nesting level is absurdly high.


Quick Decoder Summary
---------------------

.. autosummary::

    ~pyjson5.decode
    ~pyjson5.decode_latin1
    ~pyjson5.decode_buffer
    ~pyjson5.decode_callback
    ~pyjson5.decode_io
    ~pyjson5.load
    ~pyjson5.loads
    ~pyjson5.Json5DecoderException
    ~pyjson5.Json5NestingTooDeep
    ~pyjson5.Json5EOF
    ~pyjson5.Json5IllegalCharacter
    ~pyjson5.Json5ExtraData
    ~pyjson5.Json5IllegalType


Full Decoder Description
------------------------

.. autofunction:: pyjson5.decode

.. autofunction:: pyjson5.decode_latin1

.. autofunction:: pyjson5.decode_buffer

.. autofunction:: pyjson5.decode_callback

.. autofunction:: pyjson5.decode_io


Decoder Compatibility Functions
-------------------------------

.. autofunction:: pyjson5.load

.. autofunction:: pyjson5.loads


Decoder Exceptions
------------------

.. inheritance-diagram::
    pyjson5.Json5DecoderException
    pyjson5.Json5NestingTooDeep
    pyjson5.Json5EOF
    pyjson5.Json5IllegalCharacter
    pyjson5.Json5ExtraData
    pyjson5.Json5IllegalType

.. autoexception:: pyjson5.Json5DecoderException
    :members:
    :inherited-members:

.. autoexception:: pyjson5.Json5NestingTooDeep
    :members:
    :inherited-members:

.. autoexception:: pyjson5.Json5EOF
    :members:
    :inherited-members:

.. autoexception:: pyjson5.Json5IllegalCharacter
    :members:
    :inherited-members:

.. autoexception:: pyjson5.Json5ExtraData
    :members:
    :inherited-members:

.. autoexception:: pyjson5.Json5IllegalType
    :members:
    :inherited-members:

Serializer / Encoder
====================

The serializer returns ASCII data that can safely be used in an HTML template.
Apostrophes, ampersands, greater-than, and less-then signs are encoded as
unicode escaped sequences. E.g. this snippet is safe for any and all input:

.. code:: html

    "<a onclick='alert(" + encode(data) + ")'>show message</a>"

Unless the input contains infinite or NaN values, the result will be valid
`JSON <https://tools.ietf.org/html/rfc8259>`_ data.


Quick Encoder Summary
---------------------

.. autosummary::

    ~pyjson5.encode
    ~pyjson5.encode_bytes
    ~pyjson5.encode_callback
    ~pyjson5.encode_io
    ~pyjson5.encode_noop
    ~pyjson5.dump
    ~pyjson5.dumps
    ~pyjson5.Options
    ~pyjson5.Json5EncoderException
    ~pyjson5.Json5UnstringifiableType


Full Encoder Description
------------------------

.. autofunction:: pyjson5.encode

.. autofunction:: pyjson5.encode_bytes

.. autofunction:: pyjson5.encode_callback

.. autofunction:: pyjson5.encode_io

.. autofunction:: pyjson5.encode_noop

.. autoclass:: pyjson5.Options
    :members:
    :inherited-members:


Encoder Compatibility Functions
-------------------------------

.. autofunction:: pyjson5.dump

.. autofunction:: pyjson5.dumps


Encoder Exceptions
------------------

.. inheritance-diagram::
    pyjson5.Json5Exception
    pyjson5.Json5EncoderException
    pyjson5.Json5UnstringifiableType

.. autoclass:: pyjson5.Json5EncoderException
    :members:
    :inherited-members:

.. autoclass:: pyjson5.Json5UnstringifiableType
    :members:
    :inherited-members:

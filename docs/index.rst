PyJSON5
=======

A JSON5 serializer and parser library for Python 3.5 and later.


The serializer returns ASCII data that can safely be used in an HTML template.
Apostrophes, ampersands, greater-than, and less-then signs are encoded as
unicode escaped sequences. E.g. this snippet is safe for any and all input:

.. code:: html

    "<a onclick='alert(" + encode(data) + ")'>show message</a>"

Unless the input contains infinite or NaN values, the result will be valid
`JSON <https://tools.ietf.org/html/rfc8259>`_ data.


All valid `JSON5 1.0.0 <https://spec.json5.org/>`_ and
`JSON <https://tools.ietf.org/html/rfc8259>`_ data can be read,
unless the nesting level is absurdly high.


Installation
------------

.. code:: bash

    $ pip install pyjson5


Table of Contents
-----------------

.. toctree::
    :maxdepth: 2

    encoder.rst
    decoder.rst
    exceptions.rst
    performance.rst
    changelog.md


Quick Summary
-------------

.. autosummary::

    ~pyjson5.decode
    ~pyjson5.decode_buffer
    ~pyjson5.decode_callback
    ~pyjson5.decode_io
    ~pyjson5.load
    ~pyjson5.loads
    ~pyjson5.encode
    ~pyjson5.encode_bytes
    ~pyjson5.encode_callback
    ~pyjson5.encode_io
    ~pyjson5.encode_noop
    ~pyjson5.dump
    ~pyjson5.dumps
    ~pyjson5.Options
    ~pyjson5.Json5EncoderException
    ~pyjson5.Json5DecoderException


Compatibility
-------------

At least CPython / PyPy 3.5, and a C++11 compatible compiler (such as GCC 5.2+) is needed.


-------------------------------------------------------------------------------

:ref:`Glossary / Index <genindex>`

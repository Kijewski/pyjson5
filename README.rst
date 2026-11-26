PyJSON5
==========

.. image:: https://img.shields.io/github/actions/workflow/status/Kijewski/pyjson5/ci.yml?branch=main&style=flat-square&logo=github&logoColor=white&label=ci
   :target: https://github.com/Kijewski/pyjson5/actions/workflows/ci.yml
   :alt: GitHub Workflow Status

.. image:: https://img.shields.io/readthedocs/pyjson5?style=flat-square&logo=readthedocs&logoColor=white
   :target: https://pyjson5.k6i.de/
   :alt: Documentation

.. image:: https://img.shields.io/pypi/v/pyjson5?style=flat-square&logo=pypi&logoColor=white&label=version
   :target: https://pypi.org/project/pyjson5/
   :alt: PyPI

.. image:: https://static.pepy.tech/badge/pyjson5/month
   :target: https://pyoven.org/package/pyjson5
   :alt: Monthly downloads

A JSON5 serializer and parser library for Python 3 written in
`Cython <http://cython.org/>`_.


Serializer
----------

The serializer returns ASCII data that can safely be used in an HTML template.
Apostrophes, ampersands, greater-than, and less-then signs are encoded as
unicode escaped sequences. E.g. this snippet is safe for any and all input:

.. code:: html

    "<a onclick='alert(" + encode(data) + ")'>show message</a>"

Unless the input contains infinite or NaN values, the result will be valid
`JSON <https://tools.ietf.org/html/rfc8259>`_ data.


Parser
------

All valid `JSON5 1.0.0 <https://spec.json5.org/>`_ and
`JSON <https://tools.ietf.org/html/rfc8259>`_ data can be read,
unless the nesting level is absurdly high.

Functions
---------

You can find the full documentation online at https://pyjson5.readthedocs.io/en/latest/.
Or simply call ``help(pyjson5)``. :-)

The library supplies load(s) and dump(s) functions, so you can use it as a
drop-in replacement for Python's builtin ``json`` module, but you *should*
use the functions ``encode_*()`` and ``decode_*()`` instead.

Compatibility
-------------

At least CPython 3.9 or a recent Pypy3 version is needed.

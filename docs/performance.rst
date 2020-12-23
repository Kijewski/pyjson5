Performance
===========

This library is written in Cython for a better performance than a pure-Python implementation could give you.


Decoder Performance
-------------------

The library is a bit slower than the shipped ``json`` module for *pure* JSON data.
If you know that your input does not use JSON5 extension, then this library is probably not what you need.

* Dataset: https://github.com/zemirco/sf-city-lots-json
* Version: 3.9.1 (default, Dec  8 2020, 07:51:42)
* CPU: AMD Ryzen 7 2700 @ 3.7GHz
* :func:`pyjson5.decode`: **3.18** s ± 9.79 ms per loop *(lower is better)*
* :func:`json.loads`: **2.66** s ± 9.78 ms per loop
* The decoder works correcty: ``json.loads(content) == pyjson5.loads(content)``


Encoder Performance
-------------------

The encoder generates pure JSON data if there are no infinite or NaN values in the input, which are invalid in JSON.
The serialized data is XML-safe, i.e. there are no cheverons ``<>``, ampersands ``&``, apostrophes ``'`` or control characters in the output.
The output is always ASCII regardless if you call :func:`pyjson5.encode` or :func:`pyjson5.encode_bytes`.

* Dataset: https://github.com/zemirco/sf-city-lots-json
* Version: 3.9.1 (default, Dec  8 2020, 07:51:42)
* CPU: AMD Ryzen 7 2700 @ 3.7GHz
* :func:`pyjson5.encode`: **3.21** s ± 25.1 per loop *(lower is better)*
* :func:`json.dumps`: **3.82** s ± 20.4 ms per loop
* :func:`json.dumps` + :func:`xml.sax.saxutils.escape`: **3.95** s ± 18.3 ms per loop
* The encoder works correcty: ``obj == json.loads(pyjson5.encode(obj, floatformat='%.16e'))``

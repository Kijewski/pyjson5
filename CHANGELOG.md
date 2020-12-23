### 1.4.9

* Faster floating-point number decoding using [fast_double_parser](https://github.com/lemire/fast_double_parser) by Daniel Lemire

### 1.4.8

* Update up Unicode 13.0.0
* Don't use non-standard ``__uint128``
* Add PyPy compatibility
* Add ``decode_utf8(byte-like)``

### 1.4.7

* Allow ``\uXXXX`` sequences in identifier names
* Update to Unicode 12.1.0
* Optimized encoder and decoder for a little better speed
* Setup basic CI environment
* Parse ``\uXXXX`` in literal keys
* Understand "0."
* Add CI tests
* Reject unescaped newlines in strings per spec
* Allow overriding default quotation mark
* Make Options objects pickle-able
* Bump major version number

### 0.4.6

* Fix PyUnicode_AsUTF8AndSize()'s signature

### 0.4.5

* Don't use C++14 features, only C++11

### 0.4.4

* Better documentation
* Optimized encoder for a little better speed

### 0.4.3

* Initial release

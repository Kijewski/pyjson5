# distutils: language = c++
# cython: embedsignature = True

include 'src/_imports.pyx'
include 'src/_exceptions.pyx'
include 'src/_unicode.pyx'
include 'src/_readers.pyx'
include 'src/_decoder.pyx'


__all__ = 'decode', 'decode_str', 'decode_latin1', 'UNLIMITED',

from cython import final
from cpython cimport dict, int, list, long, tuple, type
from cpython.bool cimport PyBool_Check
from cpython.buffer cimport (
    PyObject_GetBuffer, PyObject_GetBuffer, PyBUF_CONTIG_RO, PyBuffer_Release,
)
from cpython.bytes cimport (
    PyBytes_AsStringAndSize, PyBytes_FromStringAndSize, PyBytes_Check,
)
from cpython.datetime cimport datetime, date, time
from cpython.float cimport PyFloat_Check, PyFloat_AsDouble
from cpython.int cimport PyInt_Check
from cpython.long cimport PyLong_FromString, PyLong_Check
from cpython.object cimport PyObject
from cpython.unicode cimport PyUnicode_Check
from libcpp cimport bool as boolean
from libcpp.vector cimport vector as std_vector


cdef extern from '<cstddef>' namespace 'std' nogil:
    ctypedef unsigned long size_t


cdef extern from '<cstdint>' namespace 'std' nogil:
    ctypedef unsigned char uint8_t
    ctypedef unsigned short uint16_t
    ctypedef unsigned long uint32_t
    ctypedef unsigned long long uint64_t

    ctypedef signed char int8_t
    ctypedef signed short int16_t
    ctypedef signed long int32_t
    ctypedef signed long long int64_t


cdef extern from '<cstdio>' namespace 'std' nogil:
    int snprintf(char *buffer, size_t buf_size, const char *format, ...)
    size_t strlen(const char *s)


cdef extern from '<cstring>' namespace 'std' nogil:
    void memcpy(void *dest, const void *std, size_t count)
    size_t strlen(const char *s)


cdef extern from '<cmath>' nogil:
    enum:
        FP_INFINITE, FP_NAN, FP_NORMAL, FP_SUBNORMAL, FP_ZERO

cdef extern from '<cmath>' namespace 'std' nogil:
    int fpclassify(...)


cdef extern from '<utility>' namespace 'std' nogil:
    void swap[T](T&, T&)


cdef extern from 'Python.h':
    ctypedef signed char Py_UCS1
    ctypedef signed short Py_UCS2
    ctypedef signed long Py_UCS4

    enum:
        PyUnicode_1BYTE_KIND
        PyUnicode_2BYTE_KIND
        PyUnicode_4BYTE_KIND

    int PyUnicode_READY(object o) except -1
    Py_ssize_t PyUnicode_GET_LENGTH(object o)
    int PyUnicode_KIND(object o)
    Py_UCS1 *PyUnicode_1BYTE_DATA(object o)
    Py_UCS2 *PyUnicode_2BYTE_DATA(object o)
    Py_UCS4 *PyUnicode_4BYTE_DATA(object o)

    boolean Py_EnterRecursiveCall(const char *where) except True
    void Py_LeaveRecursiveCall()

    bint Py_UNICODE_ISALPHA(Py_UCS4 ch) nogil
    bint Py_UNICODE_ISDIGIT(Py_UCS4 ch) nogil
    bint Py_UNICODE_IS_SURROGATE(Py_UCS4 ch) nogil
    bint Py_UNICODE_IS_HIGH_SURROGATE(Py_UCS4 ch) nogil
    bint Py_UNICODE_IS_LOW_SURROGATE(Py_UCS4 ch) nogil
    Py_UCS4 Py_UNICODE_JOIN_SURROGATES(Py_UCS4 high, Py_UCS4 low) nogil

    object PyUnicode_FromKindAndData(int kind, const void *buf, Py_ssize_t size)
    char *PyUnicode_AsUTF8AndSize(object o, Py_ssize_t *size) except NULL

    object PyByteArray_FromStringAndSize(const char *string, Py_ssize_t length)

    object CallFunction 'PyObject_CallFunction'(PyObject *cb, const char *format, ...)


cdef extern from 'native.hpp' namespace 'JSON5EncoderCpp' nogil:
    int32_t cast_to_int32(...)
    uint32_t cast_to_uint32(...)

    ctypedef boolean AlwaysTrue
    boolean obj_has_iter(object obj)

    ctypedef char EscapeDctItem[8]
    struct EscapeDct:
        EscapeDctItem items[0x10000]
    EscapeDct ESCAPE_DCT


cdef type Decimal, Mapping
cdef object saferepr

from collections.abc import Mapping
from decimal import Decimal
from pprint import saferepr

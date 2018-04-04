from libcpp cimport bool as boolean
from libcpp.vector cimport vector
from cpython.buffer cimport (
    PyObject_GetBuffer, PyObject_GetBuffer, PyBUF_CONTIG_RO, PyBuffer_Release,
)
from cpython.bytes cimport PyBytes_AsStringAndSize, PyBytes_FromStringAndSize
from cpython.long cimport PyLong_FromString
from cpython.object cimport PyObject


cdef extern from '<cstdint>' namespace 'std' nogil:
    ctypedef unsigned char uint8_t
    ctypedef unsigned short uint16_t
    ctypedef unsigned long uint32_t
    ctypedef unsigned long long uint64_t

    ctypedef signed char int8_t
    ctypedef signed short int16_t
    ctypedef signed long int32_t
    ctypedef signed long long int64_t


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


cdef extern from 'native.hpp' namespace 'JSON5EncoderCpp' nogil:
    int32_t cast_to_int32(...)
    uint32_t cast_to_uint32(...)

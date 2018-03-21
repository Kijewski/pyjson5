from libcpp cimport bool as boolean
from cpython.bytes cimport PyBytes_AsStringAndSize


cdef extern from '<cstdint>' namespace 'std' nogil:
    ctypedef unsigned char uint8_t
    ctypedef unsigned short uint16_t
    ctypedef unsigned long uint32_t

    ctypedef signed char int8_t
    ctypedef signed short int16_t
    ctypedef signed long int32_t


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


cdef extern from 'native.hpp' namespace 'JSON5EncoderCpp' nogil:
    int32_t cast_to_int32(...)
    uint32_t cast_to_uint32(...)

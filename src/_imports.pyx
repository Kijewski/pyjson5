from cython import final, no_gc, auto_pickle, freelist
from cpython cimport dict, int, list, long, tuple, type
from cpython.bool cimport PyBool_Check
from cpython.buffer cimport (
    PyObject_GetBuffer, PyObject_GetBuffer, PyBUF_CONTIG_RO, PyBuffer_Release,
)
from cpython.bytes cimport (
    PyBytes_AsStringAndSize, PyBytes_FromStringAndSize, PyBytes_Check,
)
from cpython.datetime cimport datetime, date, time
from cpython.dict cimport PyDict_SetItem
from cpython.float cimport PyFloat_Check, PyFloat_AsDouble
from cpython.int cimport PyInt_Check
from cpython.list cimport PyList_Append
from cpython.long cimport PyLong_FromString, PyLong_Check
from cpython.object cimport PyObject
from cpython.type cimport PyType_Check
from cpython.unicode cimport PyUnicode_Check, PyUnicode_FromEncodedObject, PyUnicode_Format
from libcpp cimport bool as boolean


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
    void memset(void *dest, char value, size_t count)
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


cdef extern from 'src/native.hpp' namespace 'JSON5EncoderCpp' nogil:
    int32_t cast_to_int32(...)
    uint32_t cast_to_uint32(...)

    ctypedef boolean AlwaysTrue
    boolean obj_has_iter(object obj)

    ctypedef char EscapeDctItem[8]
    cppclass EscapeDct:
        EscapeDctItem items[0x100]
        boolean is_escaped(uint32_t c)
        Py_ssize_t find_unescaped_range(const Py_UCS1 *start, Py_ssize_t length)
        Py_ssize_t find_unescaped_range(const Py_UCS2 *start, Py_ssize_t length)
        Py_ssize_t find_unescaped_range(const Py_UCS4 *start, Py_ssize_t length)
    EscapeDct ESCAPE_DCT

    enum:
        VERSION_LENGTH
    const char VERSION[]

    enum:
        LONGDESCRIPTION_LENGTH
    const char LONGDESCRIPTION[]

    const char HEX[]


cdef extern from 'src/_unicode_cat_of.hpp' namespace 'JSON5EncoderCpp' nogil:
    unsigned unicode_cat_of(uint32_t codepoint)


cdef extern from 'src/_stack_heap_string.hpp' namespace 'JSON5EncoderCpp' nogil:
    cdef cppclass StackHeapString [T]:
        const T *data()
        Py_ssize_t size()
        boolean push_back(T codepoint) except False


cdef extern from 'src/_decoder_recursive_select.hpp' namespace 'JSON5EncoderCpp' nogil:
    cdef enum DrsKind:
        DRS_fail,
        DRS_null, DRS_true, DRS_false, DRS_inf, DRS_nan,
        DRS_string, DRS_number, DRS_recursive

    DrsKind drs_lookup[128]


cdef extern from 'Python.h':
    enum:
        PyUnicode_WCHAR_KIND
        PyUnicode_1BYTE_KIND
        PyUnicode_2BYTE_KIND
        PyUnicode_4BYTE_KIND

    int PyUnicode_READY(object o) except -1
    Py_ssize_t PyUnicode_GET_LENGTH(object o) nogil
    int PyUnicode_KIND(object o) nogil
    boolean PyUnicode_IS_ASCII(object) nogil
    Py_UCS1 *PyUnicode_1BYTE_DATA(object o) nogil
    Py_UCS2 *PyUnicode_2BYTE_DATA(object o) nogil
    Py_UCS4 *PyUnicode_4BYTE_DATA(object o) nogil

    boolean Py_EnterRecursiveCall(const char *where) except True
    void Py_LeaveRecursiveCall()

    bint Py_UNICODE_ISALPHA(Py_UCS4 ch) nogil
    bint Py_UNICODE_ISDIGIT(Py_UCS4 ch) nogil
    bint Py_UNICODE_IS_SURROGATE(Py_UCS4 ch) nogil
    bint Py_UNICODE_IS_HIGH_SURROGATE(Py_UCS4 ch) nogil
    bint Py_UNICODE_IS_LOW_SURROGATE(Py_UCS4 ch) nogil
    Py_UCS4 Py_UNICODE_JOIN_SURROGATES(Py_UCS4 high, Py_UCS4 low) nogil

    object PyUnicode_FromKindAndData(int kind, const void *buf, Py_ssize_t size)
    const char *PyUnicode_AsUTF8AndSize(object o, Py_ssize_t *size) except NULL

    object PyDict_SetDefault(object p, object key, object value)

    object CallFunction 'PyObject_CallFunction'(PyObject *cb, const char *format, ...)
    object CallObject 'PyObject_CallObject'(PyObject *cb, PyObject *args)

    ctypedef signed long Py_hash
    ctypedef signed short wchar_t

    enum:
        SSTATE_NOT_INTERNED
        SSTATE_INTERNED_MORTAL
        SSTATE_INTERNED_IMMORTAL

    ctypedef struct __ascii_object_state:
        uint8_t interned
        uint8_t kind
        boolean compact
        boolean ascii
        boolean ready

    ctypedef struct PyASCIIObject:
        Py_ssize_t length
        Py_hash hash
        wchar_t *wstr
        __ascii_object_state state

    ctypedef struct PyVarObject:
        pass

    ctypedef struct PyBytesObject:
        PyVarObject ob_base
        Py_hash ob_shash
        char ob_sval[1]

    AlwaysTrue ErrNoMemory 'PyErr_NoMemory'() except True
    void *ObjectRealloc 'PyObject_Realloc'(void *p, size_t n)
    void ObjectFree 'PyObject_Free'(void *p)
    object ObjectInit 'PyObject_INIT'(PyObject *obj, type cls)
    PyVarObject *ObjectInitVar 'PyObject_InitVar'(PyVarObject *obj, type cls, Py_ssize_t size)

    double PyOS_string_to_double(const char *s, char **endp, PyObject *overflow_exception) except? -1.0
    object PyLong_FromString(const char *str, char **pend, int base)


ctypedef struct AsciiObject:
    PyASCIIObject base
    char data[1]


cdef extern from 'src/native.hpp' nogil:
    boolean expect 'JSON5Encoder_expect'(boolean actual, boolean expected)
    void unreachable 'JSON5Encoder_unreachable'()


cdef type Decimal, Mapping, IOBase
cdef object saferepr

from collections.abc import Mapping
from decimal import Decimal
from io import IOBase
from pprint import saferepr

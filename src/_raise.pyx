cdef boolean _raise_unclosed(str what, Py_ssize_t start) except False:
    raise Json5EOF(f'Unclosed {what} starting near {start}')


cdef boolean _raise_stray_character(str what, Py_ssize_t where) except False:
    raise Json5IllegalCharacter(f'Stray {what} near {where}')


cdef boolean _raise_expected_sc(str char_a, uint32_t char_b, Py_ssize_t near, uint32_t found) except False:
    raise Json5IllegalCharacter(f'Expected {char_a} or U+{char_b:04x} near {near}, found U+{found:04x}')


cdef boolean _raise_expected_s(str char_a, Py_ssize_t near, uint32_t found) except False:
    raise Json5IllegalCharacter(f'Expected {char_a} near {near}, found U+{found:04x}')


cdef boolean _raise_expected_c(uint32_t char_a, Py_ssize_t near, uint32_t found) except False:
    raise Json5IllegalCharacter(f'Expected {char_a:04x} near {near}, found U+{found:04x}')


cdef boolean _raise_extra_data(uint32_t found, Py_ssize_t where) except False:
    raise Json5ExtraData(f'Extra data U+{found:04X} near {where}')


cdef boolean _raise_no_data(Py_ssize_t where) except False:
    raise Json5ExtraData(f'No JSON data found near {where}')

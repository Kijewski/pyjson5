cdef AlwaysTrue _raise_unclosed(str what, Py_ssize_t start) except True:
    raise Json5EOF(f'Unclosed {what} starting near {start}')


cdef AlwaysTrue _raise_stray_character(str what, Py_ssize_t where) except True:
    raise Json5IllegalCharacter(f'Stray {what} near {where}')


cdef AlwaysTrue _raise_expected_sc(str char_a, uint32_t char_b, Py_ssize_t near, uint32_t found) except True:
    raise Json5IllegalCharacter(f'Expected {char_a} or U+{char_b:04x} near {near}, found U+{found:04x}')


cdef AlwaysTrue _raise_expected_s(str char_a, Py_ssize_t near, uint32_t found) except True:
    raise Json5IllegalCharacter(f'Expected {char_a} near {near}, found U+{found:04x}')


cdef AlwaysTrue _raise_expected_c(uint32_t char_a, Py_ssize_t near, uint32_t found) except True:
    raise Json5IllegalCharacter(f'Expected U+{char_a:04x} near {near}, found U+{found:04x}')


cdef AlwaysTrue _raise_extra_data(uint32_t found, Py_ssize_t where) except True:
    raise Json5ExtraData(f'Extra data U+{found:04X} near {where}')


cdef AlwaysTrue _raise_no_data(Py_ssize_t where) except True:
    raise Json5EOF(f'No JSON data found near {where}')

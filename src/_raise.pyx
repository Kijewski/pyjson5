cdef AlwaysTrue _raise_unclosed(const char *what, Py_ssize_t start) except True:
    raise Json5EOF(f'Unclosed {what} starting near {start}')


cdef AlwaysTrue _raise_stray_character(const char *what, Py_ssize_t where) except True:
    raise Json5IllegalCharacter(f'Stray {what} near {where}')


cdef AlwaysTrue _raise_expected_sc(const char *char_a, uint32_t char_b, Py_ssize_t near, uint32_t found) except True:
    raise Json5IllegalCharacter(f'Expected {char_a} or U+{char_b:04x} near {near}, found U+{found:04x}')


cdef AlwaysTrue _raise_expected_s(const char *char_a, Py_ssize_t near, uint32_t found) except True:
    raise Json5IllegalCharacter(f'Expected {char_a} near {near}, found U+{found:04x}')


cdef AlwaysTrue _raise_expected_c(uint32_t char_a, Py_ssize_t near, uint32_t found) except True:
    raise Json5IllegalCharacter(f'Expected U+{char_a:04x} near {near}, found U+{found:04x}')


cdef AlwaysTrue _raise_extra_data(uint32_t found, object datum, Py_ssize_t where) except True:
    raise Json5ExtraData(f'Extra data U+{found:04X} near {where}', datum, f'{found:c}')


cdef AlwaysTrue _raise_no_data(Py_ssize_t where) except True:
    raise Json5EOF(f'No JSON data found near {where}')


cdef AlwaysTrue _raise_unframed_data(uint32_t found, object datum, Py_ssize_t where) except True:
    raise Json5ExtraData(f'Lost unframed data near {where}', datum, f'{found:c}')


cdef AlwaysTrue _raise_unstringifiable(object data) except True:
    raise Json5UnstringifiableType(f'Unstringifiable type(data)={type(data)!r}', data)

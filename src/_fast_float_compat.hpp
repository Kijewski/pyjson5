#pragma once
#include "../third-party/fast_float/include/fast_float/float_common.h"

/* This header file is a shim to handle 'enum class' in Cython, which doesn't
 * namespace properly. */
namespace chars_format {
    using chars_format = fast_float::chars_format;

    constexpr chars_format fmt_json_or_infnan = fast_float::chars_format::json_or_infnan;
}

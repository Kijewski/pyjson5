#pragma once
#include "../third-party/fast_float/include/fast_float/float_common.h"

/* This header file is a shim to handle 'enum class' in Cython, which doesn't
 * namespace properly. */
namespace chars_format {
    using chars_format = fast_float::chars_format;

    constexpr chars_format fmt_json_or_infnan = fast_float::chars_format::json_or_infnan;
}

namespace check_floats {
    /*
     * Check for invalid exponents on strings which represent floats.
     * Does not guarantee that the float is valid -- only that *if* it has an
     * exponent, the exponent is valid.
     *
     * Checks in this order:
     *
     * - no exponent                OK (false)
     *
     * - nothing after exponent     FAIL (true)
     *
     * - a sign (+/-) at the end    FAIL (true)
     *
     * - anything after exponent    FAIL (true)
     *   and optional sign
     *   which is not a digit
     *
     * - nothing failed?            OK (false)
     */
    bool has_invalid_exponent(const std::string &s) {
        auto pos = s.find_first_of("e");
        if (pos == std::string::npos) return false;

        if (++pos >= s.size()) return true;

        if (s[pos] == '+' || s[pos] == '-') {
            if (++pos >= s.size()) return true;
        }

        // Now check the exponent part for a dot ('.') or any other non-digit
        // character
        for (; pos < s.size(); ++pos) {
            if (!isdigit(s[pos])) return true;
        }

        return false;
    }
}

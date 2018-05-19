#pragma once

#include <array>
#include <cstdint>
#include <type_traits>

namespace JSON5EncoderCpp {
inline namespace {

template <class From>
constexpr std::uint32_t cast_to_uint32(
    const From &unsigned_from,
    typename std::enable_if<
        !std::is_signed<From>::value
    >::type* = nullptr
) {
    return static_cast<std::uint32_t>(unsigned_from);
}

template <class From>
constexpr std::uint32_t cast_to_uint32(
    const From &from,
    typename std::enable_if<
        std::is_signed<From>::value
    >::type* = nullptr
) {
    using UnsignedFrom = typename std::make_unsigned<From>::type;
    UnsignedFrom unsigned_from = static_cast<UnsignedFrom>(from);
    return cast_to_uint32(unsigned_from);
}

template <class From>
constexpr std::int32_t cast_to_int32(const From &from) {
    std::uint32_t unsigned_from = cast_to_uint32(from);
    return static_cast<std::int32_t>(unsigned_from);
}

struct AlwaysTrue {
    constexpr inline AlwaysTrue() = default;
    inline ~AlwaysTrue() = default;

    constexpr inline AlwaysTrue(const AlwaysTrue&) = default;
    constexpr inline AlwaysTrue(AlwaysTrue&&) = default;
    constexpr inline AlwaysTrue &operator =(const AlwaysTrue&) = default;
    constexpr inline AlwaysTrue &operator =(AlwaysTrue&&) = default;

    template <class T>
    constexpr inline AlwaysTrue(T&&) : AlwaysTrue() {}

    template <class T>
    constexpr inline bool operator ==(T&&) const { return true; }

    constexpr inline operator bool () const { return true; }
};

bool obj_has_iter(const PyObject *obj) {
    auto *i = Py_TYPE(obj)->tp_iter;
    return (i != nullptr) && (i != &_PyObject_NextNotImplemented);
}

constexpr char HEX[] = "0123456789abcdef";

struct EscapeDct {
    using Item = std::array<char, 8>;  // 7 are needed, 1 length
    static constexpr std::size_t length = 0x100;

    Item items[length];
    unsigned __int128 is_escaped_array;

    static constexpr Item unicode_item(size_t index) {
        return {{
            '\\',
            'u',
            HEX[(index / 16 / 16 / 16 % 16)],
            HEX[(index / 16 / 16      % 16)],
            HEX[(index / 16           % 16)],
            HEX[(index                % 16)],
            0,
            6,
        }};
    }

    static constexpr Item escaped_item(char chr) {
        return {{ '\\', chr, 0, 0, 0, 0, 0, 2 }};
    }

    static constexpr Item verbatim_item(size_t chr) {
        return {{ (char) (unsigned char) chr, 0, 0, 0, 0, 0, 0, 1 }};
    }

    inline bool is_escaped(std::uint32_t c) const {
        return (c >= 0x0080) || (is_escaped_array & (
            static_cast<unsigned __int128>(1) <<
            static_cast<std::uint8_t>(c)
        ));
    }

    inline std::size_t find_unescaped_range(const Py_UCS1 *start, Py_ssize_t length) const {
        Py_ssize_t index = 0;
        while ((index < length) && !is_escaped(start[index])) {
            ++index;
        }
        return index;
    }

    inline std::size_t find_unescaped_range(const Py_UCS2 *start, Py_ssize_t length) const {
        Py_ssize_t index = 0;
        while ((index < length) && !is_escaped(start[index])) {
            ++index;
        }
        return index;
    }

    inline std::size_t find_unescaped_range(const Py_UCS4 *start, Py_ssize_t length) const {
        Py_ssize_t index = 0;
        while ((index < length) && !is_escaped(start[index])) {
            ++index;
        }
        return index;
    }

    constexpr EscapeDct() :
        items(),
        is_escaped_array(static_cast<unsigned __int128>(0) - 1)
    {
        for (std::size_t i = 0; i < length; ++i) {
            items[i] = unicode_item(i);
        }
        for (std::size_t i = 0x20; i < 0x7f; ++i) {
            switch (i) {
                case '"': case '\'': case '&': case '<': case '>': case '\\':
                    break;
                default:
                    items[i] = verbatim_item(i);

                    is_escaped_array &= ~(
                        static_cast<unsigned __int128>(1) <<
                        static_cast<std::uint8_t>(i)
                    );
            }
        }
        items[(std::uint8_t) '\\'] = escaped_item('\\');
        items[(std::uint8_t) '\b'] = escaped_item('b');
        items[(std::uint8_t) '\f'] = escaped_item('f');
        items[(std::uint8_t) '\n'] = escaped_item('n');
        items[(std::uint8_t) '\r'] = escaped_item('r');
        items[(std::uint8_t) '\t'] = escaped_item('t');
    }
};

const EscapeDct ESCAPE_DCT;

const char VERSION[] =
#   include "./VERSION"
;
static constexpr std::size_t VERSION_LENGTH = sizeof(VERSION) - 1;

const char LONGDESCRIPTION[] =
#   include "./DESCRIPTION"
;
static constexpr std::size_t LONGDESCRIPTION_LENGTH = sizeof(LONGDESCRIPTION) - 1;

}
}

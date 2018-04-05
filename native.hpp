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

struct EscapeDct {
    using Item = std::array<char, 8>;  // 7 are needed, 1 length
    static constexpr std::size_t length = 0x10000;

    Item items[length];

    static constexpr Item unicode_item(size_t index) {
        constexpr char HEX[] = "0123456789abcdef";
        return {
            '\\',
            'u',
            HEX[(index / 16 / 16 / 16 % 16)],
            HEX[(index / 16 / 16      % 16)],
            HEX[(index / 16           % 16)],
            HEX[(index                % 16)],
            0,
            6,
        };
    }

    static constexpr Item escaped_item(char chr) {
        return { '\\', chr, 0, 0, 0, 0, 0, 2 };
    }

    static constexpr Item verbatim_item(size_t chr) {
        return { (char) (unsigned char) chr, 0, 0, 0, 0, 0, 0, 1 };
    }

    constexpr EscapeDct() : items() {
        for (std::size_t i = 0; i < length; ++i) {
            items[i] = unicode_item(i);
        }
        for (std::size_t i = 0x20; i < 0x7f; ++i) {
            switch (i) {
                case '"': case '&': case '<': case '>':
                    break;
                default:
                    items[i] = verbatim_item(i);
            }
        }
        items['\\'] = escaped_item('\\');
        items['\b'] = escaped_item('b');
        items['\f'] = escaped_item('f');
        items['\n'] = escaped_item('n');
        items['\r'] = escaped_item('r');
        items['\t'] = escaped_item('t');
        items['/' ] = escaped_item('/');
    }
};

const EscapeDct ESCAPE_DCT;

}
}

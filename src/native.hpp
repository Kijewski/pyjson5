#pragma once

#include <array>
#include <cstdint>
#include <type_traits>

namespace JSON5EncoderCpp {

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
    return cast_to_uint32(static_cast<typename std::make_unsigned<From>::type>(from));
}

template <class From>
constexpr std::int32_t cast_to_int32(const From &from) {
    return static_cast<std::int32_t>(cast_to_uint32(from));
}

struct AlwaysTrue {
    inline AlwaysTrue() = default;
    inline ~AlwaysTrue() = default;

    inline AlwaysTrue(const AlwaysTrue&) = default;
    inline AlwaysTrue(AlwaysTrue&&) = default;
    inline AlwaysTrue &operator =(const AlwaysTrue&) = default;
    inline AlwaysTrue &operator =(AlwaysTrue&&) = default;

    template <class T>
    inline AlwaysTrue(T&&) : AlwaysTrue() {}

    template <class T>
    inline bool operator ==(T&&) const { return true; }

    inline operator bool () const { return true; }
};

bool obj_has_iter(const PyObject *obj) {
    auto *i = Py_TYPE(obj)->tp_iter;
    return (i != nullptr) && (i != &_PyObject_NextNotImplemented);
}

constexpr char HEX[] = "0123456789abcdef";

struct EscapeDct {
    using Item = std::array<char, 8>;  // 7 are needed, 1 length
    static constexpr std::size_t length = 0x100;
    using Items = Item[length];

    static const Items items;
    static const unsigned __int128 is_escaped_array;

    static inline bool is_escaped(std::uint32_t c) {
        return (c >= 0x0080) || (is_escaped_array & (
            static_cast<unsigned __int128>(1) <<
            static_cast<std::uint8_t>(c)
        ));
    }

    template <class S>
    static inline std::size_t find_unescaped_range(const S *start, Py_ssize_t length) {
        Py_ssize_t index = 0;
        while ((index < length) && !is_escaped(start[index])) {
            ++index;
        }
        return index;
    }
};

#include "./_escape_dct.hpp"

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

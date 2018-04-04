#pragma once

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

}
}

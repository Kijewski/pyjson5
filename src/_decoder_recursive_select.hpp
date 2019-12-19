#ifndef JSON5EncoderCpp_decoder_recursive_select
#define JSON5EncoderCpp_decoder_recursive_select

#include <cstdint>

namespace JSON5EncoderCpp {
inline namespace {

enum DrsKind : std::uint8_t {
    DRS_fail,
    DRS_null, DRS_true, DRS_false, DRS_inf, DRS_nan,
    DRS_string, DRS_number, DRS_recursive,
};

static const DrsKind drs_lookup[128] = {
    /* 00-08 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 08-10 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 10-18 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 18-20 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 20-28 */      DRS_fail,      DRS_fail, /*"*/DRS_string,    DRS_fail,      DRS_fail,      DRS_fail,   /*'*/DRS_string, DRS_fail,
    /* 28-30 */      DRS_fail,      DRS_fail,      DRS_fail, /*+*/DRS_number,    DRS_fail, /*-*/DRS_number, /*.*/DRS_number, DRS_fail,
    /* 30-38 */ /*0*/DRS_number,    DRS_number,    DRS_number,    DRS_number,    DRS_number,    DRS_number,      DRS_number, DRS_number,
    /* 38-40 */ /*8*/DRS_number,    DRS_number,    DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 40-48 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 48-50 */      DRS_fail, /*I*/DRS_inf,       DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,   /*N*/DRS_nan,    DRS_fail,
    /* 50-58 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 58-60 */      DRS_fail,      DRS_fail,      DRS_fail, /*[*/DRS_recursive, DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 60-68 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,   /*f*/DRS_false,  DRS_fail,
    /* 68-70 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail,   /*n*/DRS_null,   DRS_fail,
    /* 70-78 */      DRS_fail,      DRS_fail,      DRS_fail,      DRS_fail, /*t*/DRS_true,      DRS_fail,        DRS_fail,   DRS_fail,
    /* 78-80 */      DRS_fail,      DRS_fail,      DRS_fail, /*{*/DRS_recursive, DRS_fail,      DRS_fail,        DRS_fail,   DRS_fail,
};

}
}

#endif

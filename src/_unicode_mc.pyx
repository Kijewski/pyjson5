# http://www.fileformat.info/info/unicode/category/Mc/list.htm
cdef boolean _is_mc(uint32_t c) nogil:
    if expect(c <= 0x00FF, True):
        return False
    elif expect(c <= 0xFFFF, True):
        return (
            (c == 0x00000903) or
            (c == 0x0000093b) or
            (0x0000093e <= c and c <= 0x00000940) or
            (0x00000949 <= c and c <= 0x0000094c) or
            (0x0000094e <= c and c <= 0x0000094f) or
            (0x00000982 <= c and c <= 0x00000983) or
            (0x000009be <= c and c <= 0x000009c0) or
            (0x000009c7 <= c and c <= 0x000009c8) or
            (0x000009cb <= c and c <= 0x000009cc) or
            (c == 0x000009d7) or
            (c == 0x00000a03) or
            (0x00000a3e <= c and c <= 0x00000a40) or
            (c == 0x00000a83) or
            (0x00000abe <= c and c <= 0x00000ac0) or
            (c == 0x00000ac9) or
            (0x00000acb <= c and c <= 0x00000acc) or
            (0x00000b02 <= c and c <= 0x00000b03) or
            (c == 0x00000b3e) or
            (c == 0x00000b40) or
            (0x00000b47 <= c and c <= 0x00000b48) or
            (0x00000b4b <= c and c <= 0x00000b4c) or
            (c == 0x00000b57) or
            (0x00000bbe <= c and c <= 0x00000bbf) or
            (0x00000bc1 <= c and c <= 0x00000bc2) or
            (0x00000bc6 <= c and c <= 0x00000bc8) or
            (0x00000bca <= c and c <= 0x00000bcc) or
            (c == 0x00000bd7) or
            (0x00000c01 <= c and c <= 0x00000c03) or
            (0x00000c41 <= c and c <= 0x00000c44) or
            (0x00000c82 <= c and c <= 0x00000c83) or
            (c == 0x00000cbe) or
            (0x00000cc0 <= c and c <= 0x00000cc4) or
            (0x00000cc7 <= c and c <= 0x00000cc8) or
            (0x00000cca <= c and c <= 0x00000ccb) or
            (0x00000cd5 <= c and c <= 0x00000cd6) or
            (0x00000d02 <= c and c <= 0x00000d03) or
            (0x00000d3e <= c and c <= 0x00000d40) or
            (0x00000d46 <= c and c <= 0x00000d48) or
            (0x00000d4a <= c and c <= 0x00000d4c) or
            (c == 0x00000d57) or
            (0x00000d82 <= c and c <= 0x00000d83) or
            (0x00000dcf <= c and c <= 0x00000dd1) or
            (0x00000dd8 <= c and c <= 0x00000ddf) or
            (0x00000df2 <= c and c <= 0x00000df3) or
            (0x00000f3e <= c and c <= 0x00000f3f) or
            (c == 0x00000f7f) or
            False
        )
    else:
        return (
            (0x0000102b <= c and c <= 0x0000102c) or
            (c == 0x00001031) or
            (c == 0x00001038) or
            (0x0000103b <= c and c <= 0x0000103c) or
            (0x00001056 <= c and c <= 0x00001057) or
            (0x00001062 <= c and c <= 0x00001064) or
            (0x00001067 <= c and c <= 0x0000106d) or
            (0x00001083 <= c and c <= 0x00001084) or
            (0x00001087 <= c and c <= 0x0000108c) or
            (c == 0x0000108f) or
            (0x0000109a <= c and c <= 0x0000109c) or
            (c == 0x000017b6) or
            (0x000017be <= c and c <= 0x000017c5) or
            (0x000017c7 <= c and c <= 0x000017c8) or
            (0x00001923 <= c and c <= 0x00001926) or
            (0x00001929 <= c and c <= 0x0000192b) or
            (0x00001930 <= c and c <= 0x00001931) or
            (0x00001933 <= c and c <= 0x00001938) or
            (0x00001a19 <= c and c <= 0x00001a1a) or
            (c == 0x00001a55) or
            (c == 0x00001a57) or
            (c == 0x00001a61) or
            (0x00001a63 <= c and c <= 0x00001a64) or
            (0x00001a6d <= c and c <= 0x00001a72) or
            (c == 0x00001b04) or
            (c == 0x00001b35) or
            (c == 0x00001b3b) or
            (0x00001b3d <= c and c <= 0x00001b41) or
            (0x00001b43 <= c and c <= 0x00001b44) or
            (c == 0x00001b82) or
            (c == 0x00001ba1) or
            (0x00001ba6 <= c and c <= 0x00001ba7) or
            (c == 0x00001baa) or
            (c == 0x00001be7) or
            (0x00001bea <= c and c <= 0x00001bec) or
            (c == 0x00001bee) or
            (0x00001bf2 <= c and c <= 0x00001bf3) or
            (0x00001c24 <= c and c <= 0x00001c2b) or
            (0x00001c34 <= c and c <= 0x00001c35) or
            (c == 0x00001ce1) or
            (0x00001cf2 <= c and c <= 0x00001cf3) or
            (c == 0x00001cf7) or
            (0x0000302e <= c and c <= 0x0000302f) or
            (0x0000a823 <= c and c <= 0x0000a824) or
            (c == 0x0000a827) or
            (0x0000a880 <= c and c <= 0x0000a881) or
            (0x0000a8b4 <= c and c <= 0x0000a8c3) or
            (0x0000a952 <= c and c <= 0x0000a953) or
            (c == 0x0000a983) or
            (0x0000a9b4 <= c and c <= 0x0000a9b5) or
            (0x0000a9ba <= c and c <= 0x0000a9bb) or
            (0x0000a9bd <= c and c <= 0x0000a9c0) or
            (0x0000aa2f <= c and c <= 0x0000aa30) or
            (0x0000aa33 <= c and c <= 0x0000aa34) or
            (c == 0x0000aa4d) or
            (c == 0x0000aa7b) or
            (c == 0x0000aa7d) or
            (c == 0x0000aaeb) or
            (0x0000aaee <= c and c <= 0x0000aaef) or
            (c == 0x0000aaf5) or
            (0x0000abe3 <= c and c <= 0x0000abe4) or
            (0x0000abe6 <= c and c <= 0x0000abe7) or
            (0x0000abe9 <= c and c <= 0x0000abea) or
            (c == 0x0000abec) or
            (c == 0x00011000) or
            (c == 0x00011002) or
            (c == 0x00011082) or
            (0x000110b0 <= c and c <= 0x000110b2) or
            (0x000110b7 <= c and c <= 0x000110b8) or
            (c == 0x0001112c) or
            (c == 0x00011182) or
            (0x000111b3 <= c and c <= 0x000111b5) or
            (0x000111bf <= c and c <= 0x000111c0) or
            (0x0001122c <= c and c <= 0x0001122e) or
            (0x00011232 <= c and c <= 0x00011233) or
            (c == 0x00011235) or
            (0x000112e0 <= c and c <= 0x000112e2) or
            (0x00011302 <= c and c <= 0x00011303) or
            (0x0001133e <= c and c <= 0x0001133f) or
            (0x00011341 <= c and c <= 0x00011344) or
            (0x00011347 <= c and c <= 0x00011348) or
            (0x0001134b <= c and c <= 0x0001134d) or
            (c == 0x00011357) or
            (0x00011362 <= c and c <= 0x00011363) or
            (0x00011435 <= c and c <= 0x00011437) or
            (0x00011440 <= c and c <= 0x00011441) or
            (c == 0x00011445) or
            (0x000114b0 <= c and c <= 0x000114b2) or
            (c == 0x000114b9) or
            (0x000114bb <= c and c <= 0x000114be) or
            (c == 0x000114c1) or
            (0x000115af <= c and c <= 0x000115b1) or
            (0x000115b8 <= c and c <= 0x000115bb) or
            (c == 0x000115be) or
            (0x00011630 <= c and c <= 0x00011632) or
            (0x0001163b <= c and c <= 0x0001163c) or
            (c == 0x0001163e) or
            (c == 0x000116ac) or
            (0x000116ae <= c and c <= 0x000116af) or
            (c == 0x000116b6) or
            (0x00011720 <= c and c <= 0x00011721) or
            (c == 0x00011726) or
            (0x00011a07 <= c and c <= 0x00011a08) or
            (c == 0x00011a39) or
            (0x00011a57 <= c and c <= 0x00011a58) or
            (c == 0x00011a97) or
            (c == 0x00011c2f) or
            (c == 0x00011c3e) or
            (c == 0x00011ca9) or
            (c == 0x00011cb1) or
            (c == 0x00011cb4) or
            (0x00016f51 <= c and c <= 0x00016f7e) or
            (0x0001d165 <= c and c <= 0x0001d166) or
            (0x0001d16d <= c and c <= 0x0001d172) or
            False
        )

#   ranges = []
#   last = -2
#   for x in xx:
#       if x == last + 1:
#           ranges[-1][1] = x
#       else:
#           ranges.append([x, x])
#       last = x
#
#   p = '    (\n'
#   for start, end in ranges:
#       if start < end:
#           p += f'        (0x{start:08x} <= c and c <= 0x{end:08x}) or\n'
#       else:
#           p += f'        (c == 0x{start:08x}) or\n'
#   p += '        False\n    )\n'
#

# http://www.fileformat.info/info/unicode/category/Mn/list.htm
cdef boolean _is_mn(uint32_t c) nogil:
    if expect(c <= 0x00FF, True):
        return False
    elif expect(c <= 0xFFFF, True):
        return (
            (0x00000300 <= c and c <= 0x0000036f) or
            (0x00000483 <= c and c <= 0x00000487) or
            (0x00000591 <= c and c <= 0x000005bd) or
            (c == 0x000005bf) or
            (0x000005c1 <= c and c <= 0x000005c2) or
            (0x000005c4 <= c and c <= 0x000005c5) or
            (c == 0x000005c7) or
            (0x00000610 <= c and c <= 0x0000061a) or
            (0x0000064b <= c and c <= 0x0000065f) or
            (c == 0x00000670) or
            (0x000006d6 <= c and c <= 0x000006dc) or
            (0x000006df <= c and c <= 0x000006e4) or
            (0x000006e7 <= c and c <= 0x000006e8) or
            (0x000006ea <= c and c <= 0x000006ed) or
            (c == 0x00000711) or
            (0x00000730 <= c and c <= 0x0000074a) or
            (0x000007a6 <= c and c <= 0x000007b0) or
            (0x000007eb <= c and c <= 0x000007f3) or
            (0x00000816 <= c and c <= 0x00000819) or
            (0x0000081b <= c and c <= 0x00000823) or
            (0x00000825 <= c and c <= 0x00000827) or
            (0x00000829 <= c and c <= 0x0000082d) or
            (0x00000859 <= c and c <= 0x0000085b) or
            (0x000008d4 <= c and c <= 0x000008e1) or
            (0x000008e3 <= c and c <= 0x00000902) or
            (c == 0x0000093a) or
            (c == 0x0000093c) or
            (0x00000941 <= c and c <= 0x00000948) or
            (c == 0x0000094d) or
            (0x00000951 <= c and c <= 0x00000957) or
            (0x00000962 <= c and c <= 0x00000963) or
            (c == 0x00000981) or
            (c == 0x000009bc) or
            (0x000009c1 <= c and c <= 0x000009c4) or
            (c == 0x000009cd) or
            (0x000009e2 <= c and c <= 0x000009e3) or
            (0x00000a01 <= c and c <= 0x00000a02) or
            (c == 0x00000a3c) or
            (0x00000a41 <= c and c <= 0x00000a42) or
            (0x00000a47 <= c and c <= 0x00000a48) or
            (0x00000a4b <= c and c <= 0x00000a4d) or
            (c == 0x00000a51) or
            (0x00000a70 <= c and c <= 0x00000a71) or
            (0x00000a81 <= c and c <= 0x00000a82) or
            (c == 0x00000abc) or
            (0x00000ac1 <= c and c <= 0x00000ac5) or
            (0x00000ac7 <= c and c <= 0x00000ac8) or
            (c == 0x00000acd) or
            (0x00000ae2 <= c and c <= 0x00000ae3) or
            (0x00000afa <= c and c <= 0x00000aff) or
            (c == 0x00000b01) or
            (c == 0x00000b3c) or
            (c == 0x00000b3f) or
            (0x00000b41 <= c and c <= 0x00000b44) or
            (c == 0x00000b4d) or
            (c == 0x00000b56) or
            (0x00000b62 <= c and c <= 0x00000b63) or
            (c == 0x00000b82) or
            (c == 0x00000bc0) or
            (c == 0x00000bcd) or
            (c == 0x00000c00) or
            (0x00000c3e <= c and c <= 0x00000c40) or
            (0x00000c46 <= c and c <= 0x00000c48) or
            (0x00000c4a <= c and c <= 0x00000c4d) or
            (0x00000c55 <= c and c <= 0x00000c56) or
            (0x00000c62 <= c and c <= 0x00000c63) or
            (c == 0x00000c81) or
            (c == 0x00000cbc) or
            (c == 0x00000cbf) or
            (c == 0x00000cc6) or
            (0x00000ccc <= c and c <= 0x00000ccd) or
            (0x00000ce2 <= c and c <= 0x00000ce3) or
            (0x00000d00 <= c and c <= 0x00000d01) or
            (0x00000d3b <= c and c <= 0x00000d3c) or
            (0x00000d41 <= c and c <= 0x00000d44) or
            (c == 0x00000d4d) or
            (0x00000d62 <= c and c <= 0x00000d63) or
            (c == 0x00000dca) or
            (0x00000dd2 <= c and c <= 0x00000dd4) or
            (c == 0x00000dd6) or
            (c == 0x00000e31) or
            (0x00000e34 <= c and c <= 0x00000e3a) or
            (0x00000e47 <= c and c <= 0x00000e4e) or
            (c == 0x00000eb1) or
            (0x00000eb4 <= c and c <= 0x00000eb9) or
            (0x00000ebb <= c and c <= 0x00000ebc) or
            (0x00000ec8 <= c and c <= 0x00000ecd) or
            (0x00000f18 <= c and c <= 0x00000f19) or
            (c == 0x00000f35) or
            (c == 0x00000f37) or
            (c == 0x00000f39) or
            (0x00000f71 <= c and c <= 0x00000f7e) or
            (0x00000f80 <= c and c <= 0x00000f84) or
            (0x00000f86 <= c and c <= 0x00000f87) or
            (0x00000f8d <= c and c <= 0x00000f97) or
            (0x00000f99 <= c and c <= 0x00000fbc) or
            (c == 0x00000fc6) or
            False
        )
    else:
        return (
            (0x0000102d <= c and c <= 0x00001030) or
            (0x00001032 <= c and c <= 0x00001037) or
            (0x00001039 <= c and c <= 0x0000103a) or
            (0x0000103d <= c and c <= 0x0000103e) or
            (0x00001058 <= c and c <= 0x00001059) or
            (0x0000105e <= c and c <= 0x00001060) or
            (0x00001071 <= c and c <= 0x00001074) or
            (c == 0x00001082) or
            (0x00001085 <= c and c <= 0x00001086) or
            (c == 0x0000108d) or
            (c == 0x0000109d) or
            (0x0000135d <= c and c <= 0x0000135f) or
            (0x00001712 <= c and c <= 0x00001714) or
            (0x00001732 <= c and c <= 0x00001734) or
            (0x00001752 <= c and c <= 0x00001753) or
            (0x00001772 <= c and c <= 0x00001773) or
            (0x000017b4 <= c and c <= 0x000017b5) or
            (0x000017b7 <= c and c <= 0x000017bd) or
            (c == 0x000017c6) or
            (0x000017c9 <= c and c <= 0x000017d3) or
            (c == 0x000017dd) or
            (0x0000180b <= c and c <= 0x0000180d) or
            (0x00001885 <= c and c <= 0x00001886) or
            (c == 0x000018a9) or
            (0x00001920 <= c and c <= 0x00001922) or
            (0x00001927 <= c and c <= 0x00001928) or
            (c == 0x00001932) or
            (0x00001939 <= c and c <= 0x0000193b) or
            (0x00001a17 <= c and c <= 0x00001a18) or
            (c == 0x00001a1b) or
            (c == 0x00001a56) or
            (0x00001a58 <= c and c <= 0x00001a5e) or
            (c == 0x00001a60) or
            (c == 0x00001a62) or
            (0x00001a65 <= c and c <= 0x00001a6c) or
            (0x00001a73 <= c and c <= 0x00001a7c) or
            (c == 0x00001a7f) or
            (0x00001ab0 <= c and c <= 0x00001abd) or
            (0x00001b00 <= c and c <= 0x00001b03) or
            (c == 0x00001b34) or
            (0x00001b36 <= c and c <= 0x00001b3a) or
            (c == 0x00001b3c) or
            (c == 0x00001b42) or
            (0x00001b6b <= c and c <= 0x00001b73) or
            (0x00001b80 <= c and c <= 0x00001b81) or
            (0x00001ba2 <= c and c <= 0x00001ba5) or
            (0x00001ba8 <= c and c <= 0x00001ba9) or
            (0x00001bab <= c and c <= 0x00001bad) or
            (c == 0x00001be6) or
            (0x00001be8 <= c and c <= 0x00001be9) or
            (c == 0x00001bed) or
            (0x00001bef <= c and c <= 0x00001bf1) or
            (0x00001c2c <= c and c <= 0x00001c33) or
            (0x00001c36 <= c and c <= 0x00001c37) or
            (0x00001cd0 <= c and c <= 0x00001cd2) or
            (0x00001cd4 <= c and c <= 0x00001ce0) or
            (0x00001ce2 <= c and c <= 0x00001ce8) or
            (c == 0x00001ced) or
            (c == 0x00001cf4) or
            (0x00001cf8 <= c and c <= 0x00001cf9) or
            (0x00001dc0 <= c and c <= 0x00001df9) or
            (0x00001dfb <= c and c <= 0x00001dff) or
            (0x000020d0 <= c and c <= 0x000020dc) or
            (c == 0x000020e1) or
            (0x000020e5 <= c and c <= 0x000020f0) or
            (0x00002cef <= c and c <= 0x00002cf1) or
            (c == 0x00002d7f) or
            (0x00002de0 <= c and c <= 0x00002dff) or
            (0x0000302a <= c and c <= 0x0000302d) or
            (0x00003099 <= c and c <= 0x0000309a) or
            (c == 0x0000a66f) or
            (0x0000a674 <= c and c <= 0x0000a67d) or
            (0x0000a69e <= c and c <= 0x0000a69f) or
            (0x0000a6f0 <= c and c <= 0x0000a6f1) or
            (c == 0x0000a802) or
            (c == 0x0000a806) or
            (c == 0x0000a80b) or
            (0x0000a825 <= c and c <= 0x0000a826) or
            (0x0000a8c4 <= c and c <= 0x0000a8c5) or
            (0x0000a8e0 <= c and c <= 0x0000a8f1) or
            (0x0000a926 <= c and c <= 0x0000a92d) or
            (0x0000a947 <= c and c <= 0x0000a951) or
            (0x0000a980 <= c and c <= 0x0000a982) or
            (c == 0x0000a9b3) or
            (0x0000a9b6 <= c and c <= 0x0000a9b9) or
            (c == 0x0000a9bc) or
            (c == 0x0000a9e5) or
            (0x0000aa29 <= c and c <= 0x0000aa2e) or
            (0x0000aa31 <= c and c <= 0x0000aa32) or
            (0x0000aa35 <= c and c <= 0x0000aa36) or
            (c == 0x0000aa43) or
            (c == 0x0000aa4c) or
            (c == 0x0000aa7c) or
            (c == 0x0000aab0) or
            (0x0000aab2 <= c and c <= 0x0000aab4) or
            (0x0000aab7 <= c and c <= 0x0000aab8) or
            (0x0000aabe <= c and c <= 0x0000aabf) or
            (c == 0x0000aac1) or
            (0x0000aaec <= c and c <= 0x0000aaed) or
            (c == 0x0000aaf6) or
            (c == 0x0000abe5) or
            (c == 0x0000abe8) or
            (c == 0x0000abed) or
            (c == 0x0000fb1e) or
            (0x0000fe00 <= c and c <= 0x0000fe0f) or
            (0x0000fe20 <= c and c <= 0x0000fe2f) or
            (c == 0x000101fd) or
            (c == 0x000102e0) or
            (0x00010376 <= c and c <= 0x0001037a) or
            (0x00010a01 <= c and c <= 0x00010a03) or
            (0x00010a05 <= c and c <= 0x00010a06) or
            (0x00010a0c <= c and c <= 0x00010a0f) or
            (0x00010a38 <= c and c <= 0x00010a3a) or
            (c == 0x00010a3f) or
            (0x00010ae5 <= c and c <= 0x00010ae6) or
            (c == 0x00011001) or
            (0x00011038 <= c and c <= 0x00011046) or
            (0x0001107f <= c and c <= 0x00011081) or
            (0x000110b3 <= c and c <= 0x000110b6) or
            (0x000110b9 <= c and c <= 0x000110ba) or
            (0x00011100 <= c and c <= 0x00011102) or
            (0x00011127 <= c and c <= 0x0001112b) or
            (0x0001112d <= c and c <= 0x00011134) or
            (c == 0x00011173) or
            (0x00011180 <= c and c <= 0x00011181) or
            (0x000111b6 <= c and c <= 0x000111be) or
            (0x000111ca <= c and c <= 0x000111cc) or
            (0x0001122f <= c and c <= 0x00011231) or
            (c == 0x00011234) or
            (0x00011236 <= c and c <= 0x00011237) or
            (c == 0x0001123e) or
            (c == 0x000112df) or
            (0x000112e3 <= c and c <= 0x000112ea) or
            (0x00011300 <= c and c <= 0x00011301) or
            (c == 0x0001133c) or
            (c == 0x00011340) or
            (0x00011366 <= c and c <= 0x0001136c) or
            (0x00011370 <= c and c <= 0x00011374) or
            (0x00011438 <= c and c <= 0x0001143f) or
            (0x00011442 <= c and c <= 0x00011444) or
            (c == 0x00011446) or
            (0x000114b3 <= c and c <= 0x000114b8) or
            (c == 0x000114ba) or
            (0x000114bf <= c and c <= 0x000114c0) or
            (0x000114c2 <= c and c <= 0x000114c3) or
            (0x000115b2 <= c and c <= 0x000115b5) or
            (0x000115bc <= c and c <= 0x000115bd) or
            (0x000115bf <= c and c <= 0x000115c0) or
            (0x000115dc <= c and c <= 0x000115dd) or
            (0x00011633 <= c and c <= 0x0001163a) or
            (c == 0x0001163d) or
            (0x0001163f <= c and c <= 0x00011640) or
            (c == 0x000116ab) or
            (c == 0x000116ad) or
            (0x000116b0 <= c and c <= 0x000116b5) or
            (c == 0x000116b7) or
            (0x0001171d <= c and c <= 0x0001171f) or
            (0x00011722 <= c and c <= 0x00011725) or
            (0x00011727 <= c and c <= 0x0001172b) or
            (0x00011a01 <= c and c <= 0x00011a06) or
            (0x00011a09 <= c and c <= 0x00011a0a) or
            (0x00011a33 <= c and c <= 0x00011a38) or
            (0x00011a3b <= c and c <= 0x00011a3e) or
            (c == 0x00011a47) or
            (0x00011a51 <= c and c <= 0x00011a56) or
            (0x00011a59 <= c and c <= 0x00011a5b) or
            (0x00011a8a <= c and c <= 0x00011a96) or
            (0x00011a98 <= c and c <= 0x00011a99) or
            (0x00011c30 <= c and c <= 0x00011c36) or
            (0x00011c38 <= c and c <= 0x00011c3d) or
            (c == 0x00011c3f) or
            (0x00011c92 <= c and c <= 0x00011ca7) or
            (0x00011caa <= c and c <= 0x00011cb0) or
            (0x00011cb2 <= c and c <= 0x00011cb3) or
            (0x00011cb5 <= c and c <= 0x00011cb6) or
            (0x00011d31 <= c and c <= 0x00011d36) or
            (c == 0x00011d3a) or
            (0x00011d3c <= c and c <= 0x00011d3d) or
            (0x00011d3f <= c and c <= 0x00011d45) or
            (c == 0x00011d47) or
            (0x00016af0 <= c and c <= 0x00016af4) or
            (0x00016b30 <= c and c <= 0x00016b36) or
            (0x00016f8f <= c and c <= 0x00016f92) or
            (0x0001bc9d <= c and c <= 0x0001bc9e) or
            (0x0001d167 <= c and c <= 0x0001d169) or
            (0x0001d17b <= c and c <= 0x0001d182) or
            (0x0001d185 <= c and c <= 0x0001d18b) or
            (0x0001d1aa <= c and c <= 0x0001d1ad) or
            (0x0001d242 <= c and c <= 0x0001d244) or
            (0x0001da00 <= c and c <= 0x0001da36) or
            (0x0001da3b <= c and c <= 0x0001da6c) or
            (c == 0x0001da75) or
            (c == 0x0001da84) or
            (0x0001da9b <= c and c <= 0x0001da9f) or
            (0x0001daa1 <= c and c <= 0x0001daaf) or
            (0x0001e000 <= c and c <= 0x0001e006) or
            (0x0001e008 <= c and c <= 0x0001e018) or
            (0x0001e01b <= c and c <= 0x0001e021) or
            (0x0001e023 <= c and c <= 0x0001e024) or
            (0x0001e026 <= c and c <= 0x0001e02a) or
            (0x0001e8d0 <= c and c <= 0x0001e8d6) or
            (0x0001e944 <= c and c <= 0x0001e94a) or
            (0x000e0100 <= c and c <= 0x000e01ef) or
            False
        )

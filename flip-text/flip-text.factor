! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs kernel sequences ;

IN: flip-text

<PRIVATE

CONSTANT: CHARS H{
    { CHAR: A   HEX: 2200 }
    { CHAR: B   HEX: 10412 }
    { CHAR: C   HEX: 03FD }
    { CHAR: D   HEX: 15E1 }
    { CHAR: E   HEX: 018E }
    { CHAR: F   HEX: 2132 }
    { CHAR: G   HEX: 2141 }
    ! { CHAR: H   CHAR: H }
    ! { CHAR: I   CHAR: I }
    { CHAR: J   HEX: 148B }
    { CHAR: K   HEX: 004B }
    { CHAR: L   HEX: 2142 }
    { CHAR: M   CHAR: W   }
    ! { CHAR: N   CHAR: N }
    ! { CHAR: O   CHAR: O }
    { CHAR: P   HEX: 0500 }
    { CHAR: Q   HEX: 038C }
    { CHAR: R   HEX: 1D1A }
    ! { CHAR: S   CHAR: S }
    { CHAR: T   HEX: 22A5 }
    { CHAR: U   HEX: 0548 }
    { CHAR: V   HEX: 039B }
    { CHAR: W   CHAR: M   }
    ! { CHAR: X   CHAR: X }
    { CHAR: Y   HEX: 2144 }
    ! { CHAR: Z   CHAR: Z }
    { CHAR: a   HEX: 0250 }
    { CHAR: b   CHAR: q   }
    { CHAR: c   HEX: 0254 }
    { CHAR: d   CHAR: p   }
    { CHAR: e   HEX: 01DD }
    { CHAR: f   HEX: 025F }
    { CHAR: g   HEX: 1D77 } ! or 0183
    { CHAR: h   HEX: 0265 }
    { CHAR: i   HEX: 1D09 } ! or 0131
    { CHAR: j   HEX: 027E } ! or 1E37
    { CHAR: k   HEX: 029E }
    { CHAR: l   HEX: 0283 } ! or 237
    { CHAR: m   HEX: 026F }
    { CHAR: n   CHAR: u   }
    ! { CHAR: o   CHAR: o }
    { CHAR: p   CHAR: d   }
    { CHAR: q   CHAR: b   }
    { CHAR: r   HEX: 0279 }
    ! { CHAR: s   CHAR: s }
    { CHAR: t   HEX: 0287 }
    { CHAR: u   CHAR: n   }
    { CHAR: v   HEX: 028C }
    { CHAR: w   HEX: 028D }
    { CHAR: y   HEX: 028E }
    ! { CHAR: z   CHAR: z }
    ! { CHAR: 0   CHAR: 0 }
    { CHAR: 1   HEX: 21C2 }
    { CHAR: 2   HEX: 1105 }
    { CHAR: 3   HEX: 0190 } ! or 1110
    { CHAR: 4   HEX: 152D }
    ! { CHAR: 5   CHAR: 5 }
    { CHAR: 6   CHAR: 9   }
    { CHAR: 7   HEX: 2C62 }
    ! { CHAR: 8   CHAR: 8 }
    { CHAR: 9   CHAR: 6   }
    { CHAR: &   HEX: 214B }
    { CHAR: !   HEX: 00A1 }
    { CHAR: "   HEX: 201E }
    { CHAR: .   HEX: 02D9 }
    { CHAR: ;   HEX: 061B }
    { CHAR: [   CHAR: ]   }
    { CHAR: (   CHAR: )   }
    { CHAR: {   CHAR: }   }
    { CHAR: ?   HEX: 00BF }
    { CHAR: !   HEX: 00A1 }
    { CHAR: '   CHAR: ,   }
    { CHAR: <   CHAR: >   }
    { CHAR: _   HEX: 203E }
    { HEX: 203F HEX: 2040 }
    { HEX: 2045 HEX: 2046 }
    { HEX: 2234 HEX: 2235 }
    { CHAR: \r CHAR: \n   }
}

CHARS [ CHARS set-at ] assoc-each

: ch>flip ( ch -- ch' )
    dup CHARS at [ nip ] when* ;

PRIVATE>

: flip-text ( str -- str' )
    [ ch>flip ] map reverse ;



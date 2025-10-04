USING: kernel math math.bitwise math.functions ;

IN: pseudo-encrypt

: pseudo-encrypt ( x -- y )
    [ -16 shift ] keep [ 16 bits ] bi@ 3 [
        [
            1366 * 150889 + 714025 rem 714025.0 / 32767 *
            round >integer  bitxor 32 >signed
        ] keep swap
    ] times 16 shift + 32 >signed ;

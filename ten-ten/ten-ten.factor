! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math math.functions math.ranges memoize sequences
strings ;

IN: ten-ten

<PRIVATE

CONSTANT: ALPHABET "ABCDEFGHJKMNPQRVWXY0123456789"

MEMO: BASE ( -- base ) ALPHABET length ;

: p ( lat lon -- p )
    [ 90 + ] [ 180 + ] bi*
    [ 10000 * floor >fixnum ] bi@
    [ 3600000 * ] dip + ;

: tt ( p -- tt )
    [ BASE * ] keep 10 [1,b) [
        [ BASE /mod ] dip *
    ] map nip sum BASE mod + floor ;

: tt>string ( tt -- str )
    10 [ BASE /mod ALPHABET nth ] replicate
    nip reverse >string
    [ CHAR: \s 3 ] dip insert-nth
    [ CHAR: \s 7 ] dip insert-nth ;

PRIVATE>

: ten-ten ( lat lon -- tt )
    p tt tt>string ;



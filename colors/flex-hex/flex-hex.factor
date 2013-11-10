! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: colors colors.hex grouping kernel math math.parser
regexp.classes sequences ;

IN: colors.flex-hex

<PRIVATE

: hex-only ( str -- str' )
    [ dup hex-digit? [ drop CHAR: 0 ] unless ] map ;

: pad-amount ( str -- n )
    length dup 3 mod [ 3 swap - + ] unless-zero ;

: three-groups ( str -- array )
    dup pad-amount [ CHAR: 0 pad-tail ] [ 3 / group ] bi ;

: hex-rgb ( array -- array' )
    [
        8 short tail*
        2 short head
        2 CHAR: 0 pad-head
    ] map ;

PRIVATE>

: flex-hex ( str -- hex )
    "#" ?head drop hex-only three-groups hex-rgb "" join ;

: flex-hex>rgba ( str -- rgba )
    flex-hex hex>rgba ;

! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: math math.functions qw sequences ;

IN: compass

CONSTANT: directions qw{
    N NbE NNE NEbN NE NEbE ENE EbN
    E EbS ESE SEbE SE SEbS SSE SbE
    S SbW SSW SWbS SW SWbW WSW WbS
    W WbN WNW NWbW NW NWbN NNW NbW
}

: compass>string ( compass -- str )
    360/32 / round >integer 32 mod directions nth ;

: string>compass ( str -- compass )
    directions index 360/32 * ;

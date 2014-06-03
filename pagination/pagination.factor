! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators combinators.smart io kernel locals math
math.order math.parser sequences sets splitting.monotonic ;

IN: pagination

:: pages-to-show ( page #pages -- seq )
    [
        1 2 page {
            [ 2 - ]
            [ 1 - ]
            [ ]
            [ 1 + ]
            [ 2 + ]
        } cleave #pages [ 1 - ] keep
    ] output>array members
    [ 1 #pages between? ] filter ;


:: pages-to-show. ( page #pages -- )
    page #pages pages-to-show
    [ swap - 1 = ] monotonic-split { f } join
    [
        [
            [ number>string ]
            [ page = [ "[" "]" surround ] when ] bi
        ] [ "..." ] if*
    ] map " " join "<< " " >>" surround print ;

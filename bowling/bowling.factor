! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators formatting io kernel math
math.ranges math.statistics sequences ;

IN: bowling

: pin ( last ch -- pin )
    {
        { CHAR: - [ 0 ] }
        { CHAR: X [ 10 ] }
        { CHAR: / [ 10 over - ] }
        [ CHAR: 0 - ]
    } case nip ;

: pins ( str -- pins )
    f swap [ pin dup ] { } map-as nip ;

: frame ( pins -- rest frame )
    dup first 10 = 1 2 ? short cut-slice swap ;

: frames ( pins -- frames )
    9 [ frame ] replicate swap suffix ;

: bonus ( frame -- bonus )
    [ seq>> ] [ to>> tail ] [ length 3 swap - ] tri head sum ;

: scores ( frames -- scores )
    [ [ sum ] keep over 10 = [ bonus + ] [ drop ] if ] map ;

: bowl ( str -- score )
    pins frames scores sum ;

: bowl. ( str -- )
    10 [1,b] [ "%3d" sprintf ] map " | " join print
    10 "---" <array> "-+-" join print
    pins frames [
        [
            [
                [
                    {
                        { 0 [ CHAR: - ] }
                        { 10 [ CHAR: X ] }
                        [ CHAR: 0 + ]
                    } case
                ] "" map-as
            ] [
                dup length 1 > [
                    first2 + 10 = [
                        CHAR: / 1 pick set-nth
                    ] when
                ] [ drop ] if
            ] bi "%3s" sprintf
        ] map " | " join print
    ] [
        scores cum-sum
        [ "%3d" sprintf ] map " | " join print
    ] bi ;

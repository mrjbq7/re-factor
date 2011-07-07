! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: combinators formatting io kernel math sequences ;

IN: 99bottles.3

: #bottles ( n -- str )
    {
        { 1 [ "1 bottle" ] }
        { 0 [ "no more bottles" ] }
        [ "%d bottles" sprintf ]
    } case " of beer" append ;

: on-the-wall ( n -- )
    #bottles dup "%s on the wall, %s.\n" printf ;

: take-one-down ( n -- )
    "Take one down and pass it around, " write
    #bottles "%s on the wall.\n" printf ;

: take-bottles ( n -- )
    [ dup zero? ] [
        [ on-the-wall ] [ 1 - dup take-one-down ] bi
    ] until on-the-wall ;

: go-to-store ( n -- )
    "Go to the store and buy some more, " write
    #bottles "%s on the wall.\n" printf ;

: bottles ( n -- )
    [ take-bottles ] [ go-to-store ] bi ;

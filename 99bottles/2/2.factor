! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: combinators formatting io kernel math math.ranges
sequences ;

IN: 99bottles.2

: #bottles ( n -- str )
    {
        { 1 [ "1 bottle" ] }
        { 0 [ "no more bottles" ] }
        [ "%d bottles" sprintf ]
    } case " of beer" append ;

: verse ( n -- )
    dup #bottles dup "%s on the wall, %s.\n" printf
    "Take one down and pass it around, " write
    1 - #bottles "%s on the wall.\n" printf ;

: verse-0 ( -- )
    "No more bottles of beer on the wall, " write
    "no more bottles of beer." print
    "Go to the store and buy some more, " write
    "no more bottles of beer on the wall!" print ;

: bottles ( n -- )
    1 [a,b] [ verse ] each verse-0 ;


! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: formatting io kernel math math.ranges sequences ;

IN: 99bottles

: verse ( n -- )
    dup "%d bottles of beer on the wall, " printf
    dup "%d bottles of beer.\n" printf
    "Take one down and pass it around, " write
    1 - "%d bottles of beer on the wall.\n" printf ;

: verse-1 ( -- )
    "1 bottle of beer on the wall, " write
    "1 bottle of beer." print
    "Take one down and pass it around, " write
    "no more bottles of beer on the wall." print ;

: verse-0 ( -- )
    "No more bottles of beer on the wall, " write
    "no more bottles of beer." print
    "Go to the store and buy some more, " write
    "99 bottles of beer on the wall." print ;

: 99bottles ( -- )
    100 2 [a,b] [ verse ] each verse-1 verse-0 ;

MAIN: 99bottles

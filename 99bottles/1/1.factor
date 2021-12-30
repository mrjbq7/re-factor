! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: formatting io kernel math ranges sequences ;

IN: 99bottles.1

: verse ( n -- )
    dup "%d bottles of beer on the wall, " printf
    dup "%d bottles of beer.\n" printf
    "Take one down and pass it around, " write
    1 - "%d bottles of beer on the wall.\n" printf ;

: last-verse ( -- )
    "Go to the store and buy some more, " write
    "no more bottles of beer on the wall!" print ;

: bottles ( n -- )
    1 [a..b] [ verse ] each last-verse ;

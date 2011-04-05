! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io kernel literals math.ranges random sequences ;

IN: random-string

CONSTANT: valid-chars $[
    CHAR: A CHAR: Z [a,b] CHAR: a CHAR: z [a,b] append
]

: random-char ( -- ch )
    valid-chars random ;

: random-string ( n -- string )
    [ random-char ] "" replicate-as ;

: run-random-string ( -- )
    8 random-string print readln drop ;

MAIN: run-random-string

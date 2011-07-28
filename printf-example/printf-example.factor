! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: fry io io.streams.string kernel macros make math
math.parser peg.ebnf present sequences strings ;

IN: printf-example

ERROR: unknown-printf-directive ;

EBNF: parse-printf

fmt-%      = "%"    => [[ [ "%" ] ]]
fmt-c      = "c"    => [[ [ 1string ] ]]
fmt-s      = "s"    => [[ [ present ] ]]
fmt-d      = "d"    => [[ [ >integer number>string ] ]]
fmt-f      = "f"    => [[ [ >float number>string ] ]]
fmt-x      = "x"    => [[ [ >hex ] ]]
unknown    = (.)*   => [[ unknown-printf-directive ]]

strings    = fmt-c|fmt-s
numbers    = fmt-d|fmt-f|fmt-x

formats    = "%"~ (strings|numbers|fmt-%|unknown)

plain-text = (!("%").)+
                    => [[ >string '[ _ ] ]]

text       = (formats|plain-text)*
                    => [[ reverse [ [ , ] append ] map ]]

;EBNF

MACRO: printf ( format-string -- )
    parse-printf [ ] concat-as
    '[ _ { } make reverse [ write ] each ] ;

: sprintf ( format-string -- result )
    [ printf ] with-string-writer ; inline

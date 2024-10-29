! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: io io.streams.string kernel macros make math math.parser
multiline peg.ebnf present quotations sequences strings ;

IN: printf-example

EBNF: parse-printf [=[

fmt-%      = "%"   => [[ [ "%" ] ]]
fmt-c      = "c"   => [[ [ 1string ] ]]
fmt-s      = "s"   => [[ [ present ] ]]
fmt-d      = "d"   => [[ [ >integer number>string ] ]]
fmt-f      = "f"   => [[ [ >float number>string ] ]]
fmt-x      = "x"   => [[ [ >hex ] ]]
unknown    = (.)*  => [[ >string throw ]]

strings    = fmt-c|fmt-s
numbers    = fmt-d|fmt-f|fmt-x

formats    = "%"~ (strings|numbers|fmt-%|unknown)

plain-text = (!("%").)+
                   => [[ >string 1quotation ]]

text       = (formats|plain-text)*
                   => [[ [ \ , suffix ] map ]]

]=]

MACRO: printf ( format-string -- quot )
    parse-printf reverse [ ] concat-as [
        { } make reverse [ write ] each
    ] curry ;

: sprintf ( format-string -- result )
    [ printf ] with-string-writer ; inline

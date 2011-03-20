! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays combinators formatting hashtables kernel
math.parser sequences splitting ;

IN: tnetstrings

<PRIVATE

: parse-payload ( data -- remain payload payload-type )
    ":" split1 swap string>number cut unclip swapd ;

DEFER: parse-dict
DEFER: parse-list

: parse-tnetstring ( data -- remain value )
    parse-payload {
        { CHAR: # [ string>number ] }
        { CHAR: " [ ] }
        { CHAR: } [ parse-dict ] }
        { CHAR: ] [ parse-list ] }
        [ "Invalid payload type: %c" sprintf throw ]
    } case ;

: parse-list ( data -- value )
    [ { } ] [
        [ dup empty? not ] [ parse-tnetstring ] produce nip
    ] if-empty ;

: parse-pair ( data -- extra value key )
    parse-tnetstring [
        dup [ "Unbalanced dictionary store" throw ] unless
        parse-tnetstring
        dup [ "Invalid value, null not allowed" throw ] unless
    ] dip ;

: parse-dict ( data -- value )
    [ H{ } ] [
        [ dup empty? not ] [ parse-pair swap 2array ] produce
        nip >hashtable
    ] if-empty ;

PRIVATE>

: tnetstring ( data -- value )
    parse-tnetstring swap [
        "Had trailing junk: %s" sprintf throw
    ] unless-empty ;

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators formatting hashtables kernel
math math.parser sequences splitting strings ;

IN: tnetstrings

<PRIVATE

: parse-payload ( data -- remain payload payload-type )
    ":" split1 swap string>number cut unclip swapd ;

DEFER: parse-tnetstring

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

: parse-bool ( data -- ? )
    {
        { "true" [ t ] }
        { "false" [ f ] }
        [ "Invalid bool: %s" sprintf throw ]
    } case ;

: parse-null ( data -- f )
    [ f ] [ drop "Payload must be 0 length" throw ] if-empty ;

: parse-tnetstring ( data -- remain value )
    parse-payload {
        { CHAR: # [ string>number ] }
        { CHAR: " [ ] }
        { CHAR: } [ parse-dict ] }
        { CHAR: ] [ parse-list ] }
        { CHAR: ! [ parse-bool ] }
        { CHAR: ~ [ parse-null ] }
        { CHAR: , [ ] }
        [ "Invalid payload type: %c" sprintf throw ]
    } case ;

PRIVATE>

: tnetstring> ( string -- value )
    parse-tnetstring swap [
        "Had trailing junk: %s" sprintf throw
    ] unless-empty ;

<PRIVATE

DEFER: dump-tnetstring

: dump-number ( data -- string )
    number>string [ length ] keep "%d:%s#" sprintf ;

: dump-string ( data -- string )
    [ length ] keep "%d:%s\"" sprintf ;

: dump-list ( data -- string )
    [ dump-tnetstring ] map "" concat-as
    [ length ] keep "%d:%s]" sprintf ;

: dump-dict ( data -- string )
    >alist [ first2 [ dump-tnetstring ] bi@ append ] map
    "" concat-as [ length ] keep "%d:%s}" sprintf ;

: dump-bool ( ? -- string )
    "4:true!" "5:false!" ? ;

: dump-tnetstring ( data -- string )
    {
        { [ dup boolean?  ] [ dump-bool ] }
        { [ dup number?   ] [ dump-number ] }
        { [ dup string?   ] [ dump-string ] }
        { [ dup sequence? ] [ dump-list ] }
        { [ dup assoc?    ] [ dump-dict ] }
        [ "Can't serialize object" throw ]
    } cond ;

PRIVATE>

: >tnetstring ( value -- string )
    dump-tnetstring ;


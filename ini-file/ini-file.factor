! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays combinators combinators.short-circuit hashtables
io io.streams.string kernel make math namespaces sequences
strings.parser ;

IN: ini-file

<PRIVATE

SYMBOL: section
SYMBOL: option

: space? ( ch -- ? )
    {
        [ CHAR: \s = ]
        [ CHAR: \t = ]
        [ CHAR: \n = ]
        [ CHAR: \r = ]
        [ HEX: 0c = ] ! \f
        [ HEX: 0b = ] ! \v
    } 1|| ;

: escape ( ch -- ch' )
    {
        { CHAR: a [ CHAR: \a ] }
        { CHAR: b [ HEX: 08 ] } ! \b
        { CHAR: f [ HEX: 0c ] } ! \f
        { CHAR: n [ CHAR: \n ] }
        { CHAR: r [ CHAR: \r ] }
        { CHAR: t [ CHAR: \t ] }
        { CHAR: v [ HEX: 0b ] } ! \v
        { CHAR: ' [ CHAR: ' ] }
        { CHAR: " [ CHAR: " ] }
        { CHAR: \\ [ CHAR: \\ ] }
        { CHAR: ? [ CHAR: ? ] }
        { CHAR: ; [ CHAR: ; ] }
        { CHAR: [ [ CHAR: [ ] }
        { CHAR: ] [ CHAR: ] ] }
        { CHAR: = [ CHAR: = ] }
        [ bad-escape ]
    } case ;

: (unescape-string) ( str -- )
    CHAR: \\ over index [
        cut-slice [ % ] dip rest-slice
        dup empty? [ "Missing escape code" throw ] when
        unclip-slice escape , (unescape-string)
    ] [ % ] if* ;

: unescape-string ( str -- str' )
    [ (unescape-string) ] "" make ;

: unwrap ( str -- str' )
    1 swap [ length 1 - ] keep subseq ;

: uncomment ( str -- str' )
    CHAR: ; over index [ head ] when*
    CHAR: # over index [ head ] when* ;

: unspace ( str -- str' )
    [ space? ] trim ;

: unquote ( str -- str' )
    dup {
        [ length 1 > ]
        [ first CHAR: " = ]
        [ last CHAR: " = ]
    } 1&& [ unwrap ] when unescape-string ;

: section? ( line -- index/f )
    {
        [ length 1 > ]
        [ first CHAR: [ = ]
        [ CHAR: ] swap last-index ]
    } 1&& ;

: line-continues? ( line -- ? )
    { [ empty? not ] [ last CHAR: \ = ] } 1&& ;

: add-section ( -- )
    section get [ first2 >hashtable 2array , ] when* ;

: add-option ( name value -- )
    2array section get [ second push ] [ , ] if* ;

: [section] ( line -- )
    unwrap unspace unquote V{ } clone 2array section set ;

: name=value ( line -- )
    option [
        [
            swap [ first2 ] dip
        ] [
            CHAR: = over index [
                [ head unspace unquote "" ] [ 1 + tail ] 2bi
            ] [ "" "" ] if*
        ] if*
        dup line-continues? [
            dup length 1 - head unspace unquote
            dup last space? [ " " append ] unless append 2array
        ] [
            unspace unquote append add-option f
        ] if
    ] change ;

: parse-line ( line -- )
    uncomment unspace dup section? [
        add-section 1 + cut [ [section] ] [ unspace ] bi*
    ] when* [ name=value ] unless-empty ;

PRIVATE>

: read-ini ( -- assoc )
    f [ section set ] [ option set ] bi
    [ [ parse-line ] each-line add-section ] { } make
    >hashtable ;

: parse-ini ( str -- assoc )
    [ read-ini ] with-string-reader ;





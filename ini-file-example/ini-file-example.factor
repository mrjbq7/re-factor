
USING: arrays assocs combinators formatting hashtables io
io.streams.string kernel make math sequences strings
strings.parser ;

IN: ini-file-example

: unspace ( str -- str' )
    [ " \t\n\r" member? ] trim ;

: unwrap ( str -- str' )
    1 swap [ length 1 - ] keep subseq ;

: uncomment ( str -- str' )
    CHAR: # over index [ head ] when* ;


: section? ( line -- ? )
    [ first CHAR: [ = ] [ last CHAR: ] = ] bi and ;

: [section] ( line -- section )
    unwrap unspace V{ } clone 2array ;

: name=value ( section line -- section' )
    CHAR: = over index [ head ] [ 1 + tail ] 2bi
    [ unspace ] bi@ 2array over second push ;

: section, ( section/f -- )
    [ first2 >hashtable 2array , ] when* ;

: parse-line ( section line -- section' )
    uncomment unspace [
        dup section?
        [ swap section, [section] ] [ name=value ] if
    ] unless-empty ;

: read-ini ( -- assoc )
    [
        f [ parse-line ] each-line section,
    ] { } make >hashtable ;

: write-ini ( assoc -- )
    [
        [ "[%s]\n" printf ] dip
        [ "%s=%s\n" printf ] assoc-each
        nl
    ] assoc-each ;


: string>ini ( str -- assoc )
    [ read-ini ] with-string-reader ;

: ini>string ( assoc -- str )
    [ write-ini ] with-string-writer ;


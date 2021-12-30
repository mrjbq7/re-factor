! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators destructors io io.binary
io.encodings.binary io.files kernel locals math math.order
math.vectors ranges sequences strings ;

IN: thesaurus

<PRIVATE

: <thesaurus-reader> ( -- reader )
    "vocab:thesaurus/thesaurus.dat" binary <file-reader> ;

: with-thesaurus ( quot -- )
    [ <thesaurus-reader> ] dip with-input-stream ; inline

: read-int ( ptr -- n )
    seek-absolute seek-input 4 read le> ;

: read-string ( ptr -- string )
    seek-absolute seek-input "\0" read-until drop >string ;

: #words ( -- n ) 0 read-int ;

: word-position ( n -- ptr ) 4 * 4 + read-int ;

: nth-word ( n -- word ) word-position read-string ;

:: find-word ( word -- n )
    #words :> high! -1 :> low! f :> candidate!
    [ high low - 1 > ] [
        high low + 2 /i :> probe
        probe nth-word candidate!
        candidate word <=> {
            { +eq+ [ probe high! probe low! ] }
            { +lt+ [ probe low! ] }
            [ drop probe high! ]
        } case
    ] while candidate word = [ high ] [ f ] if ;

:: find-related ( word -- words )
    word find-word [
        word-position word length + 1 + :> ptr
        ptr read-int :> #related
        ptr #related [1..b] 4 v*n n+v
        [ read-int read-string ] map
    ] [ { } ] if* ;

PRIVATE>

: related-words ( word -- words )
    [ find-related ] with-thesaurus ;

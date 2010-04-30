! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs arrays fry hashtables kernel io 
io.encodings.ascii io.files make math random sequences
splitting vectors ;

IN: wordgen

: split-words ( -- seq )
    [ [ "\r\n\t.,\" " split % ] each-line ] { } make harvest ;

: word-pairs ( seq -- seq )
    dup 1 head-slice append
    dup 1 tail-slice zip ;

: word-map ( seq -- assoc )
    word-pairs H{ } clone
    [ '[ [ second ] [ first ] bi _ push-at ] each ] keep ;

: next-word ( word assoc -- word' )
    at random ;

: wordgen-from ( start n -- str )
    [ [ 1vector ] keep split-words word-map ] dip
    [ [ next-word dup pick push ] keep ] times
    2drop " " join ;

: wordgen ( n -- str )
    "the" swap wordgen-from ;


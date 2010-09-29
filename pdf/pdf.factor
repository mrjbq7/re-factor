! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors calendar combinators environment formatting
hashtables kernel io io.streams.string math.parser pdf.values
sequences ;

IN: pdf

: pdf-write ( obj -- )
    pdf-value write ;


TUPLE: pdf-info title timestamp producer author creator ;

: <pdf-info> ( -- pdf-info )
    pdf-info new
        now >>timestamp
        "Factor" >>producer
        "USER" os-env "unknown" or >>author
        "created with Factor" >>creator ;

M: pdf-info pdf-value
    [
        "<<" print [
            [ timestamp>> [ "/CreationDate " write pdf-write nl ] when* ]
            [ producer>> [ "/Producer " write pdf-write nl ] when* ]
            [ author>> [ "/Author " write pdf-write nl ] when* ]
            [ title>> [ "/Title " write pdf-write nl ] when* ]
            [ creator>> [ "/Creator " write pdf-write nl ] when* ]
        ] cleave ">>" print
    ] with-string-writer ;


TUPLE: pdf-ref object revision ;

C: <pdf-ref> pdf-ref

M: pdf-ref pdf-value
    [ object>> ] [ revision>> ] bi "%d %d R" sprintf ;


TUPLE: pdf info pages fonts ;

: <pdf> ( -- pdf )
    pdf new
        <pdf-info> >>info
        V{ } clone >>pages
        V{ } clone >>fonts ;




: pdf-object ( n quot -- )
    [ number>string write " 0 obj" print ] dip
    call "endobj" print ; inline


: pdf-stream ( quot -- string )
    [ call ] with-string-writer
    [ length "/Length" associate pdf-value ]
    [ "\nstream\n" "endstream\n" surround ] bi append ; inline



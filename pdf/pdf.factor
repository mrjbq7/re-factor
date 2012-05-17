! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors calendar combinators environment formatting
hashtables io io.streams.string kernel math math.parser
pdf.values sequences ;

IN: pdf

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


: pdf-object ( str n -- str' )
    "%d 0 obj\n" sprintf "\nendobj" surround ;

: pdf-stream ( str -- str' )
    [ length 1 + "<<\n/Length %d\n>>" sprintf ]
    [ "\nstream\n" "\nendstream" surround ] bi append ;



USE: assocs
USE: io.styles
USE: locals
USE: fonts
USE: literals
USE: make
USE: math.ranges
USE: pdf.layout
USE: splitting

:: pages>objects ( pdf -- objects )
    [
        pdf info>> pdf-value ,
        pdf-catalog ,
        { $ sans-serif-font $ serif-font $ monospace-font } {
            [ [ f >>bold? f >>italic? pdf-value , ] each ]
            [ [ t >>bold? f >>italic? pdf-value , ] each ]
            [ [ f >>bold? t >>italic? pdf-value , ] each ]
            [ [ t >>bold? t >>italic? pdf-value , ] each ]
        } cleave
        pdf pages>> length pdf-pages ,
        pdf pages>>
        dup length 16 swap 2 range boa zip
        [ pdf-page , , ] assoc-each
    ] { } make
    dup length [1,b] zip [ first2 pdf-object ] map ;

: objects>pdf ( objects -- str )
    [ "\n" join "\n" append "%PDF-1.4\n" ]
    [ pdf-trailer ] bi surround ;

! Rename to pdf>string, have it take a <pdf> object?

: pdf>string ( seq -- pdf )
    <pdf> swap pdf-layout  [
        stream>> pdf-stream over pages>> push
    ] each pages>objects objects>pdf ;

: write-pdf ( seq -- )
    pdf>string write ;



: text-to-pdf ( str -- str' )
    string-lines [
        H{ { font-name "monospace" } { font-size 10 } } <p>
    ] map pdf>string ;

USE: io.files

: file-to-pdf ( path encoding -- )
    [ file-contents text-to-pdf ]
    [ [ ".pdf" append ] dip set-file-contents ] 2bi ;


! FIXME: gadget. to take a "screenshot" into a pdf?
! FIXME: compress each pdf object to reduce file size?


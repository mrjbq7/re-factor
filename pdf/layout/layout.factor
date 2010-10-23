! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators fonts fry io.streams.string
kernel make math math.order memoize pdf.text sequences
splitting ui.text unicode.categories wrap ;

IN: pdf.layout

<PRIVATE

: word-index ( string -- n/f )
    dup [ blank? ] find drop [
        1 + swap [ blank? not ] find-from drop
    ] [ drop f ] if* ;

: word-split1 ( string -- before after/f )
    dup word-index [ cut ] [ f ] if* ;

: word-split, ( string -- )
    [ word-split1 [ , ] [ dup empty? not ] bi* ] loop drop ;

PRIVATE>

: word-split ( string -- seq )
    [ word-split, ] { } make ;

<PRIVATE

: string>elements ( string font -- elements )
    [ word-split ] dip '[
        dup word-split1 "" or
        [ _ swap text-width ] bi@
        <element>
    ] map ;

PRIVATE>

: visual-wrap ( line font line-width -- lines )
    [ string>elements ] dip dup wrap [ concat ] map ;


TUPLE: margin left right top bottom ;

: <margin> ( -- margin )
    54 54 54 54 margin boa ;

TUPLE: line-metrics spacing ;

TUPLE: canvas x y width height margin font stream foreground ;

: <canvas> ( -- canvas )
    canvas new
        0 >>x
        0 >>y
        612 >>width
        792 >>height
        54 >>margin
        sans-serif-font 12 >>size >>font
        SBUF" " >>stream ;

USE: assocs
USE: io.styles
USE: colors.constants

! Done:
! - font-name
! - font-size
! - foreground

! Todo:
! - bold
! - bold-italic
! - italic
! - background


: set-style ( canvas style -- canvas )
    {
        [
            font-name swap at "sans-serif" or {
                { "sans-serif" [ "Helvetica" ] }
                { "serif"      [ "Times"     ] }
                { "monospace"  [ "Courier"   ] }
                [ " is unsupported" append throw ]
            } case [ dup font>> ] dip >>name drop
        ]
        [
            font-size swap at 12 or
            [ dup font>> ] dip >>size drop
        ]
        [
            font-style swap at [ dup font>> ] dip {
                { bold        [ t f ] }
                { italic      [ f t ] }
                { bold-italic [ t t ] }
                [ drop f f ]
            } case [ >>bold? ] [ >>italic? ] bi* drop
        ]
        [
            foreground swap at COLOR: black or >>foreground
        ]
    } cleave ;

: width ( canvas -- n )
    [ width>> ] [ margin>> 2 * ] bi - ;

: height ( canvas -- n )
    [ height>> ] [ margin>> 2 * ] bi - ;

: x ( canvas -- n )
    [ margin>> ] [ x>> ] bi + ;

: y ( canvas -- n )
    [ height>> ] [ margin>> ] [ y>> ] tri + - ;

: inc-x ( canvas n -- )
    '[ _ + ] change-x drop ;

: inc-y ( canvas n -- )
    '[ _ + ] change-y drop ;

: inc-lines ( canvas n -- )
    [ 0 >>x ] dip over font>> size>> * inc-y ;

: avail-width ( canvas -- n )
    [ width ] [ x>> ] bi - 0 max ;

: avail-height ( canvas -- n )
    [ height ] [ y>> ] bi - 0 max ;

: avail-lines ( canvas -- n )
    [ avail-height ] [ font>> size>> ] bi /i ; ! FIXME: 1 +

: line-break ( canvas -- )
    [ font>> size>> ] keep [ + ] change-y 0 >>x drop ;

: draw-text ( canvas line -- )
    text-start
    over [ x ] [ y ] bi text-location
    over font>> text-size
    over foreground>> [ foreground-color ] when*
    over font>> over text-width swapd inc-x
    text-write
    text-end ;

: draw-lines ( canvas lines -- )
    [ drop ] [
        [ first draw-text ]
        [
            rest [ drop ] [
                text-start
                over 0 >>x [ x ] [ y ] bi text-location
                over font>> text-size
                over font>> size>> text-leading
                over foreground>> [ foreground-color ] when*
                2dup length 1 - inc-lines
                2dup [ font>> ] [ last ] bi* text-width swapd inc-x
                [ text-print ] each
                text-end
            ] if-empty
        ] 2bi
    ] if-empty ;

: text-fits? ( canvas string -- ? )
    [ dup font>> ] [ word-split1 drop ] bi*
    text-width swap avail-width <= ;



GENERIC: pdf-render ( canvas obj -- remain/f )

<PRIVATE

: (pdf-layout) ( page obj -- page )
    [ dup ] [
        dupd [ pdf-render ] with-string-writer
        '[ _ append ] [ change-stream ] curry dip
        [ [ , <canvas> ] when ] keep
    ] while drop ;

PRIVATE>

: pdf-layout ( seq -- pages )
    [ <canvas> ] dip [
        [ (pdf-layout) ] each
        dup stream>> empty? [ drop ] [ , ] if
    ] { } make ;



TUPLE: p string style ;

C: <p> p

M: p pdf-render
    [ style>> set-style ] keep
    [
        over
        [ line-break ]
        [ [ font>> ] [ width>> ] bi visual-wrap ]
        [ avail-lines short cut ] tri
        [ dupd draw-lines ] dip " " join
    ] change-string nip
    dup string>> empty? [ drop f ] when ;


TUPLE: text string style ;

C: <text> text

! FIXME: apply the text style only once when drawing multiple lines
! FIXME: need to offset first by font-size

M: text pdf-render
    [ style>> set-style ] keep
    [
        over x>> 0 > [
            2dup text-fits? [
                over [ font>> ] [ avail-width ] bi visual-wrap
                unclip-slice [ " " join over ] dip draw-text
            ] when
        ] when [ f ] [
            over
            [ line-break ]
            [ [ font>> ] [ width>> ] bi visual-wrap ]
            [ avail-lines short cut ] tri
            [ dupd draw-lines ] dip " " join
        ] if-empty
    ] change-string nip
    dup string>> empty? [ drop f ] when ;


TUPLE: hr width ;

C: <hr> hr

M: hr pdf-render
    [
        {
            [ 2/3 inc-lines ]
            [ x ]
            [ y ]
            [ 1/3 inc-lines ]
        } cleave [ line-move ] 2keep
    ] [
        width>> '[ _ + ] dip line-line stroke
    ] bi* f ;


TUPLE: br ;

C: <br> br

M: br pdf-render
    over x>> 0 > [ drop 0 >>x drop f ] [
        over avail-lines 0 > [ drop line-break f ] [ nip ] if
    ] if ;


! TUPLE: pre < p
! C: <pre> pre

! TUPLE: spacer width height ;
! C: <spacer> spacer

! TUPLE: image < span ;
! C: <image> image

! TUPLE: table-cell ;

! TUPLE: table-row ;

! TUPLE: table ;




USE: assocs
USE: formatting
USE: fonts
USE: literals
USE: locals
USE: make
USE: math.ranges
USE: pdf
USE: pdf.values

: pdf-catalog ( -- str )
    {
        "<<"
        "/Type /Catalog"
        "/Pages 15 0 R"
        ">>"
    } "\n" join ;

: pdf-pages ( n -- str )
    [
        "<<" ,
        "/Type /Pages" ,
        "/MediaBox [ 0 0 612 792 ]" ,
        [ "/Count %d" sprintf , ]
        [
            16 swap 2 range boa
            [ "%d 0 R " sprintf ] map concat
            "/Kids [ " "]" surround ,
        ] bi
        ">>" ,
    ] { } make "\n" join ;

: pdf-page ( n -- page )
    [
        "<<" ,
        "/Type /Page" ,
        "/Parent 15 0 R" ,
        1 + "/Contents %d 0 R" sprintf ,
        "/Resources << /Font <<" ,
        "/F1 3 0 R /F2 4 0 R /F3 5 0 R" ,
        "/F4 6 0 R /F5 7 0 R /F6 8 0 R" ,
        "/F7 9 0 R /F8 10 0 R /F9 11 0 R" ,
        "/F10 12 0 R /F11 13 0 R /F12 14 0 R" ,
        ">> >>" ,
        ">>" ,
    ] { } make "\n" join ;

: pdf-trailer ( objects -- str )
    [
        "xref" ,
        dup length 1 + "0 %d" sprintf ,
        "0000000000 65535 f" ,
        9 over [
            over "%010X 00000 n" sprintf , length 1 + +
        ] each drop
        "trailer" ,
        "<<" ,
        dup length 1 + "/Size %d" sprintf ,
        "/Info 1 0 R" ,
        "/Root 2 0 R" ,
        ">>" ,
        "startxref" ,
        [ length 1 + ] map-sum 9 + "%d" sprintf ,
        "%%EOF" ,
    ] { } make "\n" join ;

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

USE: pdf.layout

: >pdf ( seq -- pdf )
    <pdf> swap pdf-layout  [
        stream>> pdf-stream over pages>> push
    ] each pages>objects objects>pdf ;



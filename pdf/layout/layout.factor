! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators fonts fry io.streams.string
kernel make math math.order memoize pdf.text sequences
splitting ui.text unicode.categories wrap ;

IN: pdf.layout

: default-font ( -- font )
    <font>
        "Helvetica" >>name
        12 >>size ;

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
        default-font >>font
        SBUF" " >>stream ;

USE: assocs
USE: io.styles
USE: colors.constants

! font-name
! font-size
! bold
! bold-italic
! italic
! foreground
! background

: set-style ( canvas style -- canvas )
    [ font-size swap at 12 or [ dup font>> ] dip >>size drop ]
    [ foreground swap at COLOR: black or [ >>foreground ] when* ] bi ;

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
    over font>> size>> text-size
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
                over font>> size>> text-size
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



TUPLE: element style ;


TUPLE: p string ;

C: <p> p

M: p pdf-render
    string>> over
    [ line-break ]
    [ [ font>> ] [ width>> ] bi visual-wrap ]
    [ avail-lines short cut ] tri
    [ [ draw-lines ] [ drop line-break ] 2bi ]
    [ [ f ] [ " " join <p> ] if-empty ] bi* ;


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
            ] when ! [ f ] [ over line-break ] if-empty
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




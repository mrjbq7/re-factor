! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators fonts fry io.streams.string
kernel make math math.order memoize pdf.text sequences
splitting ui.text unicode.categories wrap ;

USE: assocs
USE: io.styles
USE: colors.constants

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

C: <margin> margin


TUPLE: canvas x y width height margin font stream foreground
background inset line-height metrics ;

: <canvas> ( -- canvas )
    canvas new
        0 >>x
        0 >>y
        612 >>width
        792 >>height
        54 54 54 54 <margin> >>margin
        sans-serif-font 12 >>size >>font
        SBUF" " >>stream
        0 >>line-height
        { 0 0 } >>inset
    dup font>> font-metrics >>metrics ;


! TODO: inset, image

! FIXME: spacing oddities if run multiple times
! FIXME: make sure can highlight text "in order"


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
        [
            ! FIXME: what's the difference?
            [ page-color swap at ]
            [ background swap at ] bi or f or >>background
        ]
        [
            inset swap at { 0 0 } or >>inset
        ]
    } cleave
    dup font>> font-metrics
    [ >>metrics ] [ height>> '[ _ max ] change-line-height ] bi ;

: width ( canvas -- n )
    [ width>> ] [ margin>> [ left>> ] [ right>> ] bi + ] bi - ;

: height ( canvas -- n )
    [ height>> ] [ margin>> [ top>> ] [ bottom>> ] bi + ] bi - ;

: x ( canvas -- n )
    [ margin>> left>> ] [ x>> ] bi + ;

: y ( canvas -- n )
    [ height>> ] [ margin>> top>> ] [ y>> ] tri + - ;

: inc-x ( canvas n -- )
    '[ _ + ] change-x drop ;

: inc-y ( canvas n -- )
    '[ _ + ] change-y drop ;

: line-break ( canvas -- )
    [ line-height>> ] keep [ + ] change-y 0 >>x
    dup metrics>> height>> >>line-height drop ;

: ?line-break ( canvas -- )
    dup x>> 0 > [ line-break ] [ drop ] if ;

: inc-lines ( canvas n -- )
    [ 0 >>x ] dip [ dup line-break ] times drop ;

: avail-width ( canvas -- n )
    [ width ] [ x>> ] bi - 0 max ;

: avail-height ( canvas -- n )
    [ height ] [ y>> ] bi - 0 max ;

: avail-lines ( canvas -- n )
    [ avail-height ] [ line-height>> ] bi /i ; ! FIXME: 1 +

: text-fits? ( canvas string -- ? )
    [ dup font>> ] [ word-split1 drop ] bi*
    text-width swap avail-width <= ;

USE: io

: draw-rect ( canvas line -- )
    over background>> [
        "0.0 G" print
        foreground-color
        [ drop [ x ] [ y ] bi ]
        [ [ font>> ] [ text-dim first2 neg ] bi* ] 2bi
        rectangle fill
    ] [ 2drop ] if* ;

: draw-text1 ( canvas line -- )
    [ draw-rect ] [
        text-start
        over font>> text-size
        over foreground>> [ foreground-color ] when*
        over [ x ] [ y ] [ metrics>> ascent>> - ] tri text-location
        over dup font>> pick text-width inc-x
        text-write
        text-end
        drop
    ] 2bi ;

: draw-text ( canvas lines -- )
    [ drop ] [
        unclip-last
        [ [ dupd draw-text1 dup line-break ] each ]
        [ [ dupd draw-text1 ] when* ] bi* drop
    ] if-empty ;

: draw-line ( canvas width -- )
    swap [ x ] [ y ] [ line-height>> 2 / - ] tri
    [ line-move ] [ [ + ] [ line-line ] bi* ] 2bi
    stroke ;




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



TUPLE: div items style ;

C: <div> div

! Insets:
! before:
!   y += inset
!   margin-left, margin-right += inset
! after:
!   y += inset
!   margin-left, margin-right -= inset


<PRIVATE

USE: xml.entities

: convert-string ( str -- str' )
    {
        { CHAR: “    "\""   }
        { CHAR: ”    "\""   }
    } escape-string-by [ 256 < ] filter ;

PRIVATE>


TUPLE: p string style ;

: <p> ( string style -- p )
    [ convert-string ] dip p boa ;

M: p pdf-render
    [ style>> set-style ] keep
    [
        over line-break
        over [ font>> ] [ avail-width ] bi visual-wrap
        over avail-lines short cut
        [ draw-text ] [ "" concat-as ] bi*
    ] change-string dup string>> empty? [ drop f ] when ;


TUPLE: text string style ;

: <text> ( string style -- text )
    [ convert-string ] dip text boa ;

M: text pdf-render
    [ style>> set-style ] keep
    [
        over x>> 0 > [
            2dup text-fits? [
                over [ font>> ] [ avail-width ] bi visual-wrap
                unclip [ "" concat-as ] dip
            ] [ over line-break f ] if
        ] [ f ] if
        [
            [ { } ] [ over [ font>> ] [ width ] bi visual-wrap ]
            if-empty
        ] dip [ prefix ] when*
        over avail-lines short cut
        [ draw-text ] [ "" concat-as ] bi*
    ] change-string dup string>> empty? [ drop f ] when ;


TUPLE: hr width ;

C: <hr> hr

M: hr pdf-render
    [ f set-style ] dip
    [
        [ dup 0 > pick avail-lines 0 > and ] [
            over avail-width over min [ - ] keep [
                [ over ] dip [ draw-line ] [ inc-x ] 2bi
            ] unless-zero dup 0 > [ over line-break ] when
        ] while
    ] change-width nip dup width>> 0 > [ drop f ] unless ;


TUPLE: br ;

C: <br> br

M: br pdf-render
    [ f set-style ] dip
    over avail-lines 0 > [ drop line-break f ] [ nip ] if ;


TUPLE: pb used? ;

: <pb> ( -- pb ) f pb boa ;

M: pb pdf-render
    dup used?>> [ f >>used? drop f ] [ t >>used? ] if nip ;



! TUPLE: pre < p
! C: <pre> pre

! TUPLE: spacer width height ;
! C: <spacer> spacer

! TUPLE: image < span ;
! C: <image> image

! TUPLE: table-cell ;

! TUPLE: table-row ;

! TUPLE: table ;




! Outlines (add to catalog):
!   /Outlines 3 0 R
!   /PageMode /UseOutlines
! Table of Contents
! Thumbnails
! Annotations
! Images


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


! Rename to pdf>string, have it take a <pdf> object?

: >pdf ( seq -- pdf )
    <pdf> swap pdf-layout  [
        stream>> pdf-stream over pages>> push
    ] each pages>objects objects>pdf ;

: write-pdf ( seq -- )
    >pdf write ;



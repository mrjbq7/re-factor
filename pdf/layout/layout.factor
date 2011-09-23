! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays combinators fonts fry io.streams.string
kernel make math math.order memoize pdf.text pdf.wrap sequences
ui.text unicode.categories ;

FROM: assocs => change-at ;
FROM: sequences => change-nth ;

USE: assocs
USE: io.styles
USE: colors.constants
USE: splitting
USE: sorting
USE: locals


IN: pdf.layout


TUPLE: margin left right top bottom ;

C: <margin> margin


TUPLE: canvas x y width height margin col-width font stream
foreground background page-color inset line-height metrics ;

: <canvas> ( -- canvas )
    canvas new
        0 >>x
        0 >>y
        612 >>width
        792 >>height
        54 54 54 54 <margin> >>margin
        612 >>col-width
        sans-serif-font 12 >>size >>font
        SBUF" " >>stream
        0 >>line-height
        { 0 0 } >>inset
    dup font>> font-metrics >>metrics ;


! TODO: inset, image

! FIXME: spacing oddities if run multiple times
! FIXME: make sure highlights text "in order"
! FIXME: don't modify layout objects in pdf-render
! FIXME: make sure unicode "works"
! FIXME: only set style differences to reduce size?

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
        [ foreground swap at COLOR: black or >>foreground ]
        [ background swap at f or >>background ]
        [ page-color swap at f or >>page-color ]
        [ inset swap at { 0 0 } or >>inset ]
    } cleave
    dup font>> font-metrics
    [ >>metrics ] [ height>> '[ _ max ] change-line-height ] bi ;

! introduce positioning of elements versus canvas?

: margin-x ( canvas -- n )
    margin>> [ left>> ] [ right>> ] bi + ;

: margin-y ( canvas -- n )
    margin>> [ top>> ] [ bottom>> ] bi + ;

: (width) ( canvas -- n )
    [ width>> ] [ margin>> [ left>> ] [ right>> ] bi + ] bi - ;

: width ( canvas -- n )
    [ (width) ] [ col-width>> ] bi min ;

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

: line-height ( canvas -- n )
    [ line-height>> ] [ inset>> first 2 * ] bi + ;

: line-break ( canvas -- )
    [ line-height>> ] keep [ + ] change-y 0 >>x
    dup metrics>> height>> >>line-height drop ;

: ?line-break ( canvas -- )
    dup x>> 0 > [ line-break ] [ drop ] if ;

: ?break ( canvas -- )
    dup x>> 0 > [ ?line-break ] [
        [ 7 + ] change-y 0 >>x drop
    ] if ;

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

: draw-page-color ( canvas -- ) ! FIXME:
    dup page-color>> [
        "0.0 G" print
        foreground-color
        [ 0 0 ] dip [ width>> ] [ height>> ] bi
        rectangle fill
    ] [ drop ] if* ;

: draw-background ( canvas line -- )
    over background>> [
        "0.0 G" print
        foreground-color
        [ drop [ x ] [ y ] bi ]
        [ [ font>> ] [ text-dim first2 neg ] bi* ] 2bi
        rectangle fill
    ] [ 2drop ] if* ;

: draw-text1 ( canvas line -- canvas )
    [ draw-background ] [
        text-start
        over font>> text-size
        over foreground>> [ foreground-color ] when*
        over [ x ] [ y ] [ metrics>> ascent>> - ] tri text-location
        over dup font>> pick text-width inc-x
        text-write
        text-end
    ] 2bi ;

: draw-text ( canvas lines -- )
    [ drop ] [
        unclip-last
        [ [ draw-text1 dup line-break ] each ]
        [ [ draw-text1 ] when* ] bi* drop
    ] if-empty ;

: draw-line ( canvas width -- )
    swap [ x ] [ y ] [ line-height>> 2 / - ] tri
    [ line-move ] [ [ + ] [ line-line ] bi* ] 2bi
    stroke ;


GENERIC: pdf-render ( canvas obj -- remain/f )

M: f pdf-render 2drop f ;

GENERIC: pdf-width ( canvas obj -- n )

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

M: div pdf-render
    [ style>> set-style ] keep
    swap '[ _ pdf-render drop ] each f ;

M: div pdf-width
    [ style>> set-style ] keep
    items>> [ dupd pdf-width ] map nip supremum ;


! Insets:
! before:
!   y += inset-height
!   margin-left, margin-right += inset-width
! after:
!   y += inset-height
!   margin-left, margin-right -= inset-width


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
        over ?line-break
        over [ font>> ] [ avail-width ] bi visual-wrap
        over avail-lines short cut
        [ draw-text ] [ "" concat-as ] bi*
    ] change-string dup string>> empty? [ drop f ] when ;

M: p pdf-width
    [ style>> set-style ] keep
    [ font>> ] [ string>> ] bi* string-lines
    [ dupd text-width ] map nip supremum ;


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

M: text pdf-width
    [ style>> set-style ] keep
    [ font>> ] [ string>> ] bi* string-lines
    [ dupd text-width ] map nip supremum ;


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

M: hr pdf-width
    nip width>> ;


TUPLE: br ;

C: <br> br

M: br pdf-render
    [ f set-style ] dip
    over avail-lines 0 > [ drop ?break f ] [ nip ] if ;

M: br pdf-width
    2drop 0 ;


TUPLE: pb used? ;

: <pb> ( -- pb ) f pb boa ;

M: pb pdf-render
    dup used?>> [ f >>used? drop f ] [ t >>used? ] if nip ;

M: pb pdf-width
    2drop 0 ;



CONSTANT: table-cell-padding 5

TUPLE: table-cell contents width ;

: <table-cell> ( contents -- table-cell )
    f table-cell boa ;

M: table-cell pdf-render
    {
        [ width>> >>col-width 0 >>x drop ]
        [
            [ [ dupd pdf-render ] map nip ] change-contents
            dup contents>> [ ] any? [ drop f ] unless
        ]
        [
            width>> table-cell-padding +
            swap margin>> [ + ] change-left drop
        ]
    } 2cleave ;

TUPLE: table-row cells ;

C: <table-row> table-row

! save y before rendering each cell
! set y to max y after all renders

M: table-row pdf-render
    {
        [ drop ?line-break ]
        [
            [let
                over y>> :> start-y
                over y>> :> max-y!
                [
                    [
                        [ start-y >>y ] dip
                        dupd pdf-render
                        over y>> max-y max max-y!
                    ] map swap max-y >>y drop
                ] change-cells

                dup cells>> [ ] any? [ drop f ] unless
            ]
        ]
        [ drop margin>> 54 >>left drop ]
        [
            drop dup width>> >>col-width
            [ ?line-break ] [ table-cell-padding inc-y ] bi
        ]
    } 2cleave ;

: col-widths ( canvas cells -- widths )
    [
        [
            contents>> [ 0 ] [
                [ [ dupd pdf-width ] [ 0 ] if* ] map supremum
            ] if-empty
        ] [ 0 ] if*
    ] map nip ;

: change-last ( seq quot -- )
    [ drop length 1 - ] [ change-nth ] 2bi ; inline

:: max-col-widths ( canvas rows -- widths )
    H{ } clone :> widths
    rows [
        cells>> canvas swap col-widths
        [ widths [ 0 or max ] change-at ] each-index
    ] each widths >alist sort-keys values

    ! make last cell larger
    dup sum 400 swap - 0 max [ + ] curry dupd change-last

    ! size down each column
    dup sum dup 400 > [ 400 swap / [ * ] curry map ] [ drop ] if ;

: set-col-widths ( canvas rows -- )
    [ max-col-widths ] keep [
        dupd cells>> [
            [ swap >>width drop ] [ drop ] if*
        ] 2each
    ] each drop ;

TUPLE: table rows widths? ;

: <table> ( rows -- table )
    f table boa ;

M: table pdf-render
    {
        [
            dup widths?>> [ 2drop ] [
                t >>widths? rows>> set-col-widths
            ] if
        ]
        [
            [
                dup rows>> empty? [ t ] [
                    [ rows>> first dupd pdf-render ] keep swap
                ] if
            ] [ [ rest ] change-rows ] until nip
            dup rows>> [ drop f ] [ drop ] if-empty
        ]
    } 2cleave ;

M: table pdf-width
    2drop 400 ; ! FIXME: hardcoded max-width


! TUPLE: pre < p
! C: <pre> pre

! TUPLE: spacer width height ;
! C: <spacer> spacer

! TUPLE: image < span ;
! C: <image> image


! Outlines (add to catalog):
!   /Outlines 3 0 R
!   /PageMode /UseOutlines
! Table of Contents
! Thumbnails
! Annotations
! Images


USE: formatting
USE: literals
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

: pdf>string ( seq -- pdf )
    <pdf> swap pdf-layout  [
        stream>> pdf-stream over pages>> push
    ] each pages>objects objects>pdf ;

: write-pdf ( seq -- )
    pdf>string write ;



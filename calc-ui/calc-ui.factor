! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors.constants combinators.smart kernel fry
math math.parser models namespaces sequences ui ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.labels
ui.gadgets.tracks ui.pens.solid ;

FROM: models => change-model ;

IN: calc-ui

TUPLE: calculator < model x y op valid ;

: <calculator> ( -- model )
    "0" calculator new-model 0 >>x ;

: reset ( model -- )
    0 >>x f >>y f >>op f >>valid "0" swap set-model ;

: display ( n -- str )
    >float number>string dup ".0" tail? [
        dup length 2 - head
    ] when ;

: set-x ( model -- model )
    dup value>> string>number >>x ;

: set-y ( model -- model )
    dup value>> string>number >>y ;

: set-op ( model quot: ( x y -- z ) -- )
    >>op set-x f >>y f >>valid drop ;

: (solve) ( model -- )
    dup [ x>> ] [ y>> ] [ op>> ] tri call( x y -- z )
    [ >>x ] keep display swap set-model ;

: solve ( model -- )
    dup op>> [ dup y>> [ set-y ] unless (solve) ] [ drop ] if ;

: negate ( model -- )
    dup valid>> [
        dup value>> "-" head?
        [ [ 1 tail ] change-model ]
        [ [ "-" prepend ] change-model ] if
    ] [ drop ] if ;

: decimal ( model -- )
    dup valid>>
    [ [ dup "." subseq? [ "." append ] unless ] change-model ]
    [ t >>valid "0." swap set-model ] if ;

: digit ( n model -- )
    dup valid>>
    [ swap [ append ] curry change-model ]
    [ t >>valid set-model ] if ;




SYMBOL: calc
<calculator> calc set-global

: [C] ( -- button )
    "C" calc get-global '[ drop _ reset ] <border-button> ;

: [±] ( -- button )
    "±" calc get-global '[ drop _ negate ] <border-button> ;

: [+] ( -- button )
    "+" calc get-global '[ drop _ [ + ] set-op ] <border-button> ;

: [-] ( -- button )
    "-" calc get-global '[ drop _ [ - ] set-op ] <border-button> ;

: [×] ( -- button )
    "×" calc get-global '[ drop _ [ * ] set-op ] <border-button> ;

: [÷] ( -- button )
    "÷" calc get-global '[ drop _ [ / ] set-op ] <border-button> ;

: [=] ( -- button )
    "=" calc get-global '[ drop _ solve ] <border-button> ;

: [.] ( -- button )
    "." calc get-global '[ drop _ decimal ] <border-button> ;

: [#] ( n -- button )
    dup calc get-global '[ drop _ _ digit ] <border-button> ;

: [_] ( -- label )
    "" <label> ;

: <display> ( -- label )
    calc get-global <label-control> { 5 5 } <border>
        { 1 1/2 } >>align
        COLOR: gray <solid> >>boundary ;

: <col> ( -- track )
    vertical <track> 1 >>fill { 5 5 } >>gap ;

: <row> ( quot -- track )
    horizontal <track> 1 >>fill { 5 5 } >>gap
    swap output>array [ 1 track-add ] each ; inline

: calc-ui ( -- )
    <col> [
        <display>
        [     [C]     [±]     [÷]    [×] ] <row>
        [ "7" [#] "8" [#] "9" [#]    [-] ] <row>
        [ "4" [#] "5" [#] "6" [#]    [+] ] <row>
        [ "1" [#] "2" [#] "3" [#]    [=] ] <row>
        [ "0" [#]     [.]     [_]    [_] ] <row>
    ] output>array [ 1 track-add ] each
    { 10 10 } <border> "Calculator" open-window ;

MAIN: calc-ui


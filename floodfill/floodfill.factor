! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors byte-arrays combinators.short-circuit images
images.viewer images.viewer.private kernel math opengl random
sequences sets ui ui.commands ui.gadgets ui.gestures ;

IN: floodfill

:: random-color ( -- color )
    255 random 255 random 255 random 255 random 4byte-array ;

CONSTANT: neighbors { { 1 0 } { 0 1 } { -1 0 } { 0 -1 } }

:: floodfill ( x y image -- ? )
    image dim>> first2 :> ( w h )
    {
        [ x 0 >= ] [ x w < ]
        [ y 0 >= ] [ y h < ]
    } 0&& [
        x y image pixel-at :> initial
        f [ drop random-color dup initial = ] loop :> color

        color x y image set-pixel-at
        V{ { x y } } :> queue

        [ queue empty? ] [
            queue pop first2 :> ( tx ty )
            neighbors [
                first2 :> ( dx dy )
                tx dx + :> nx
                ty dy + :> ny
                {
                    [ nx 0 >= ] [ nx w < ]
                    [ ny 0 >= ] [ ny h < ]
                    [ nx ny image pixel-at initial = ]
                } 0&& [
                    color nx ny image set-pixel-at
                    { nx ny } queue push
                ] when
            ] each
        ] until t
    ] [ f ] if ;

TUPLE: floodfill-gadget < image-gadget ;

: <floodfill-gadget> ( image -- gadget )
    \ floodfill-gadget new-image-gadget* ;

:: on-click ( gadget -- )
    gadget hand-rel first2 [ gl-scale >integer ] bi@ :> ( x y )
    x y gadget image>> floodfill [
        gadget delete-current-texture
        gadget relayout-1
    ] when ;

floodfill-gadget "gestures" f {
    { T{ button-up { # 1 } } on-click }
} define-command-map

MAIN-WINDOW: floodfill-window { { title "Floodfill" } }
    "vocab:floodfill/logo.png" <floodfill-gadget> >>gadgets ;

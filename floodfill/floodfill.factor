! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors byte-arrays combinators.short-circuit images
images.viewer images.viewer.private kernel math opengl random
sequences sets ui ui.commands ui.gadgets ui.gestures ;

IN: floodfill

CONSTANT: black B{ 0 0 0 255 }

:: random-color ( -- color )
    f [
        drop 255 random 255 random 255 random 255 4byte-array
        dup black =
    ] loop ;

CONSTANT: neighbors { { 1 0 } { 0 1 } { -1 0 } { 0 -1 } }

:: floodfill ( x y image -- ? )
    image dim>> first2 :> ( w h )
    {
        [ x 0 >= ] [ x w < ]
        [ y 0 >= ] [ y h < ]
        [ x y image pixel-at black = not ]
    } 0&& [

        V{ { x y } } :> queue
        random-color :> color

        color x y image set-pixel-at

        [ queue empty? ] [
            queue pop first2 :> ( tx ty )
            neighbors [
                first2 :> ( dx dy )
                tx dx + :> nx
                ty dy + :> ny
                {
                    [ nx 0 >= ] [ nx w < ]
                    [ ny 0 >= ] [ ny h < ]
                    [
                        nx ny image pixel-at
                        [ black = ] [ color = ] bi or not
                    ]
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

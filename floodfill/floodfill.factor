! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs byte-arrays combinators.short-circuit
images images.loader images.viewer images.viewer.private kernel
math opengl random sequences sets ui ui.gadgets ui.gestures
words ;

IN: floodfill

CONSTANT: neighbors { { 1 0 } { 0 1 } { -1 0 } { 0 -1 } }

CONSTANT: black B{ 0 0 0 255 }

:: random-color ( -- color )
    f [
        drop 255 random 255 random 255 random 255 4byte-array
        dup black =
    ] loop ;

TUPLE: floodfill < image-gadget ;

: <floodfill> ( image -- gadget )
    \ floodfill new-image-gadget* ;

:: on-click ( gadget -- )
    gadget hand-rel first2 [ gl-scale >integer ] bi@ :> ( x y )
    gadget image>> dup dim>> first2 :> ( image w h )

    {
        [ x 0 >= ] [ x w < ]
        [ y 0 >= ] [ y h < ]
        [ x y image pixel-at black = not ]
    } 0&& [

        HS{ { x y } } :> seen
        V{ { x y } } :> queue
        random-color :> color

        [ queue empty? ] [
            queue pop first2 :> ( tx ty )

            color tx ty image set-pixel-at

            neighbors [
                first2 :> ( dx dy )
                tx dx + :> nx
                ty dy + :> ny
                {
                    [ nx 0 >= ] [ nx w < ]
                    [ ny 0 >= ] [ ny h < ]
                    [ nx ny image pixel-at black = not ]
                    [ { nx ny } seen ?adjoin ]
                } 0&& [
                    { nx ny } queue push
                ] when
            ] each
        ] until

        gadget delete-current-texture
        gadget relayout-1
    ] when ;

floodfill "gestures" [
    [ on-click ] T{ button-up { # 1 } } pick set-at
] change-word-prop

MAIN-WINDOW: floodfill-window { { title "Floodfill" } }
    "vocab:floodfill/logo.png" load-image <floodfill> >>gadgets ;

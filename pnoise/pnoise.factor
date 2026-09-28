! https://github.com/nsf/pnoise/blob/master/test.py

USING: accessors arrays io kernel locals math math.constants
math.functions math.vectors random sequences ;
IN: pnoise

TUPLE: pnoise gradients permutations ;

<PRIVATE

: random-gradient ( -- v )
    random-unit 2pi * [ cos ] [ sin ] bi 2array ;

: smooth ( x -- y )
    [ sq ] [ -2 * 3 + ] bi * ;

:: gradient-at ( point noise -- gradient )
    point [ >integer 255 bitand noise permutations>> nth ] map
    sum 255 bitand noise gradients>> nth ;

PRIVATE>

: <pnoise> ( -- noise )
    256 [ random-gradient ] replicate
    256 <iota> >array randomize pnoise boa ;

:: noise-at ( point noise -- value )
    point vfloor :> origin
    point origin v- [ smooth ] map first2 :> ( fx fy )
    { { 0 0 } { 1 0 } { 0 1 } { 1 1 } } [
        origin v+ [ point swap v- ] [ noise gradient-at ] bi vdot
    ] map first4 :> ( v0 v1 v2 v3 )
    v0 v1 fx lerp v2 v3 fx lerp fy lerp ;

:: pnoise-demo ( -- )
    ! The reference only displays the last of its 100 frames.
    <pnoise> :> noise
    256 <iota> [| y |
        256 <iota> [| x |
            x 0.1 * y 99 128 * + 0.1 * 2array noise noise-at
            0.5 * 0.5 + 0.2 / >integer " ░▒▓██" nth
        ] "" map-as print
    ] each ;

MAIN: pnoise-demo

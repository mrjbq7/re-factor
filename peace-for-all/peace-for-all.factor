! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

! Congratulations! You found the easter egg! ❤️
! おめでとうございます！隠されたサプライズを見つけました！❤️

USING: accessors circular classes.struct kernel literals
math math.functions math.order raylib sequences strings ;

IN: peace-for-all

CONSTANT: message $[ "♥PEACE♥FOR♥ALL" <circular> ]

CONSTANT: width 800
CONSTANT: height 600
CONSTANT: font-size 24
CONSTANT: freq 0.2

CONSTANT: color-start S{ Color f 0 255 255 255 }
CONSTANT: color-end S{ Color f 255 135 0 255 }

: rows ( -- n ) height font-size /i ;

! x = (cols / 2) + (cols / 4) * sin(t * freq), kept in bounds
: wave-x ( tick -- x )
    freq * sin width 4 /i * width 2 /i +
    round >integer 0 width font-size - clamp ;

! gradient cycles over one screenful, like (range * t / lines) % range
: wave-color ( tick -- color )
    [ color-start color-end ] dip rows mod rows /f color-lerp ;

! The default raylib font has no ♥ glyph, so draw one from shapes.
:: draw-heart ( x y color -- )
    font-size :> s
    x s 0.30 * + >integer y s 0.32 * + >integer s 0.22 * color draw-circle
    x s 0.70 * + >integer y s 0.32 * + >integer s 0.22 * color draw-circle
    x s 0.50 * + y s 0.95 * + <Vector2>
    x s 0.92 * + y s 0.42 * + <Vector2>
    x s 0.08 * + y s 0.42 * + <Vector2>
    color draw-triangle ;

:: draw-glyph ( tick row -- )
    tick wave-x :> x
    row font-size * :> y
    tick message nth :> ch
    tick wave-color :> color
    ch CHAR: ♥ = [
        x y color draw-heart
    ] [
        ch 1string x y font-size color draw-text
    ] if ;

: render ( tick -- )
    begin-drawing
    BLACK clear-background
    rows <iota> [ [ + ] keep draw-glyph ] with each
    end-drawing ;

: open-peace-window ( -- )
    width height "♥ PEACE FOR ALL ♥" init-window
    30 set-target-fps ;

: peace-for-all ( -- )
    open-peace-window 0
    [ window-should-close ] [ [ 1 + ] [ render ] bi ] until
    drop close-window ;

MAIN: peace-for-all

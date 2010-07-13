! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math random sequences ;

IN: euler

: random-float ( -- n )
    0.0 1.0 uniform-random-float ;

: numbers-added ( -- n )
    0 0 [ dup 1 < ] [
        [ 1 + ] dip random-float +
    ] while drop ;

: average ( seq -- n )
    [ sum ] [ length ] bi / ;

: approximate-e ( n -- approx )
    [ numbers-added ] replicate average ;


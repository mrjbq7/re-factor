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

! Given that Pi can be estimated using the function 4 * (1 - 1/3 +
! 1/5 - 1/7 + ...) with more terms giving greater accuracy, write
! a function that calculates Pi to an accuracy of 5 decimal
! places.

USE: ranges
USE: math.vectors

: approximate-pi ( n -- approx )
    [1..b] 2 v*n 1 v-n 1 swap n/v
    [ odd? [ neg ] when ] map-index sum 4 * ;

USE: locals

: next-term ( approx i -- approx' )
    [ 2 * 1 + ] [ odd? [ neg ] when ] bi 4.0 swap / + ; inline

:: find-pi-to ( accuracy -- n approx )
    1 4.0 [
        dup pick next-term [ - ] keep
        swap abs accuracy >= [ 1 + ] 2dip
    ] loop ;

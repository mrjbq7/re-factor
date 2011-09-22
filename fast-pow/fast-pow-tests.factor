
USING: fast-pow kernel math math.functions memory random
sequences tools.test tools.time ;

IN: fast-pow.tests

[ 0.5 ] [ -1 pow2 ] unit-test
[ 1.0 ] [ 0 pow2 ] unit-test
[ 2.0 ] [ 1 pow2 ] unit-test
[ 4.0 ] [ 2 pow2 ] unit-test
[ 1024.0 ] [ 10 pow2 ] unit-test
[ 0.0009765625 ] [ -10 pow2 ] unit-test
[ 0.81225239593676 ] [ -0.3 pow2 ] unit-test
[ 3.24900958374704 ] [ 1.7 pow2 ] unit-test

: pow2-seq ( n -- seq )
    [ -20 20 uniform-random-float ] replicate ;

: pow2-test ( seq -- new old )
    [ [ pow2 drop ] [ each ] benchmark ]
    [ 2 swap [ ^ drop ] with [ each ] benchmark ] bi ;

! check its at least 25% faster
[ t ] [ 10000 pow2-seq gc pow2-test / 0.75 < ] unit-test

: relative-error ( approx value -- relative-error )
    [ - abs ] keep / ;

[ t ] [
    10000 pow2-seq
    [ [ pow2 ] [ 2 swap ^ ] bi relative-error ] map
    supremum 1e-9 <
] unit-test

! "orig" print [ 1000000 [ 2 16.3 ^ drop ] times ] time
! "pow2" print [ 1000000 [ 16.3 pow2 drop ] times ] time


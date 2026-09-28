USING: accessors arrays kernel math math.constants math.functions
math.vectors pnoise random random.mersenne-twister sequences
sorting tools.test ;
IN: pnoise.tests

! Fixed tables let us compare with Python independently of the RNG.
: <test-noise> ( -- noise )
    256 <iota> [ pi * 128 / [ cos ] [ sin ] bi 2array ] map
    256 <iota> [ 73 * 19 + 256 mod ] map pnoise boa ;

{ t } [
    {
        { { 0.25 0.5 } 0.16949281512055797 }
        { { -0.25 -1.75 } 0.12428354300318327 }
        { { 255.75 256.25 } 0.06282172178128667 }
        { { 1.5 2.125 } 0.3540122275079442 }
    } [ first2 [ <test-noise> noise-at ] dip 1e-12 ~ ] all?
] unit-test

{ t } [
    { { 0 0 } { 1 2 } { -1 -2 } { 256 -256 } }
    [ <test-noise> noise-at zero? ] all?
] unit-test

{ t } [
    { { 256 0 } { 0 256 } { -256 -256 } } [
        { -0.25 1.75 } swap v+ <test-noise> noise-at
        { -0.25 1.75 } <test-noise> noise-at 1e-12 ~
    ] all?
] unit-test

{ t } [
    <pnoise> gradients>>
    [ dup vdot 1.0 1e-12 ~ ] all?
] unit-test

{ t } [
    <pnoise> permutations>> natural-sort 256 <iota> >array =
] unit-test

{ t } [
    42 <mersenne-twister> [ <pnoise> ] with-random
    42 <mersenne-twister> [ <pnoise> ] with-random =
] unit-test

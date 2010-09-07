! Copyright (C) 2010 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.approx sequences tools.test ;

IN: math.approx.tests

[ { 3 3 13/4 16/5 19/6 22/7 } ]
[
    3+39854788871587/281474976710656
    { 1/2 1/4 1/8 1/16 1/32 1/64 }
    [ approximate ] with map
] unit-test

[ { -3 -3 -13/4 -16/5 -19/6 -22/7 } ]
[
    3+39854788871587/281474976710656 neg
    { 1/2 1/4 1/8 1/16 1/32 1/64 }
    [ approximate ] with map
] unit-test

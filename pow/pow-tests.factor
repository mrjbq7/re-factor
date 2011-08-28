
USING: pow tools.test ;

IN: pow.tests

[ 0.5 ] [ -1 pow2 ] unit-test
[ 1.0 ] [ 0 pow2 ] unit-test
[ 2.0 ] [ 1 pow2 ] unit-test
[ 4.0 ] [ 2 pow2 ] unit-test
[ 1024.0 ] [ 10 pow2 ] unit-test
[ 0.0009765625 ] [ -10 pow2 ] unit-test
[ 0.81225239593676 ] [ -0.3 pow2 ] unit-test
[ 3.24900958374704 ] [ 1.7 pow2 ] unit-test

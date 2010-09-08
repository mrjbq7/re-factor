! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: happy-numbers sequences tools.test ;

[ t ] [ 1 happy? ] unit-test
[ f ] [ 2 happy? ] unit-test

[ t ] [ 986543210 happy? ] unit-test
[ t ] [ 1234456789 happy? ] unit-test
[ t ] [ 10234456789 happy? ] unit-test
[ t ] [ 13456789298765431 happy? ] unit-test
[ t ] [ 1034567892987654301 happy? ] unit-test

[ V{ 1 7 10 13 19 23 28 31 32 44 49 } ]
[ 50 iota [ happy? ] filter ] unit-test

[ { 1 7 10 13 19 23 28 31 } ] [ 8 happy-numbers ] unit-test

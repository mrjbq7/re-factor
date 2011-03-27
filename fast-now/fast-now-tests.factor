! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: calendar fast-now kernel math tools.test tools.time ;

IN: fast-now.tests

[ f ] [ now now = ] unit-test

[ t ] [ fast-now fast-now eq? ] unit-test

[ t ] [
    [ fast-now [ dup fast-now eq? ] loop drop ] benchmark
    1075000 <
] unit-test


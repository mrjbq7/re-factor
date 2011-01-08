! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: hello-ga hello-ga.private tools.test ;

IN: hello-ga

[ 0 ] [ TARGET fitness ] unit-test

[ "" "def" ] [ "abc" "def" 0 head/tail ] unit-test
[ "a" "ef" ] [ "abc" "def" 1 head/tail ] unit-test
[ "ab" "f" ] [ "abc" "def" 2 head/tail ] unit-test
[ "abc" "" ] [ "abc" "def" 3 head/tail ] unit-test
[ "abc" "" ] [ "abc" "def" 0 tail/head ] unit-test
[ "bc" "d" ] [ "abc" "def" 1 tail/head ] unit-test
[ "c" "de" ] [ "abc" "def" 2 tail/head ] unit-test
[ "" "def" ] [ "abc" "def" 3 tail/head ] unit-test

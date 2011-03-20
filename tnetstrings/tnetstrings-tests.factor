! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: tnetstrings tools.test ;

[ H{ } ] [ "0:}" tnetstring ] unit-test

[ { } ] [ "0:]" tnetstring ] unit-test

[ "" ] [ "0:\"" tnetstring ] unit-test

[ t ] [ "4:true!" tnetstring ] unit-test

[ f ] [ "5:false!" tnetstring ] unit-test

[ H{ { "hello" { 12345678901 "this" } } } ] [
    "34:5:hello\"22:11:12345678901#4:this\"]}" tnetstring
] unit-test

[ 12345 ] [ "5:12345#" tnetstring ] unit-test

[ "this is cool" ] [
    "12:this is cool\"" tnetstring
] unit-test

[ { 12345 67890 "xxxxx" } ] [
    "24:5:12345#5:67890#5:xxxxx\"]" tnetstring
] unit-test

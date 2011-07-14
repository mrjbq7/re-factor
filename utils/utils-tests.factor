
USING: kernel math sequences tools.test utils ;

IN: utils

[ { 1 2 } ] [ 1 => 2 ] unit-test
[ { "abc" "def" } ] [ "abc" => "def" ] unit-test
[ { t "some value" } ] [ t => "some value" ] unit-test
[ { { 1 2 } { 3 4 } } ] [ { 1 => 2 3 => 4 } ] unit-test
[ H{ { 1 2 } { 3 4 } } ] [ H{ 1 => 2 3 => 4 } ] unit-test

[ 1 ] [ 1 2 [ ] min-by ] unit-test
[ 2 ] [ 1 2 [ ] max-by ] unit-test
[ "12345" ] [ "123" "12345" [ length ] max-by ] unit-test
[ "123" ] [ "123" "12345" [ length ] min-by ] unit-test

[ 4 ] [ 5 iota [ ] maximum ] unit-test
[ 0 ] [ 5 iota [ ] minimum ] unit-test
[ { "foo" } ] [ { { "foo" } { "bar" } } [ first ] maximum ] unit-test
[ { "bar" } ] [ { { "foo" } { "bar" } } [ first ] minimum ] unit-test

TUPLE: foo a b c ;

[ T{ foo f } ] [ H{ } foo new [ set-slots ] keep  ] unit-test
[ H{ { "d" 0 } } foo new set-slots ] must-fail

[ T{ foo f 1 2 3 } ]
[ H{ { "a" 1 } { "b" 2 } { "c" 3 } } foo new [ set-slots ] keep ]
unit-test

[ H{ } ] [ { } [ ] group-by ] unit-test

[ H{ { f V{ 2 2 2 } } { t V{ 1 3 1 } } } ]
[ { 1 2 3 1 2 2 } [ odd? ] group-by ] unit-test

[ f ] [ f { } deep-at ] unit-test
[ f ] [ f { "foo" } deep-at ] unit-test
[ f ] [ H{ { "a" H{ { "b" 1 } } } } { "a" "c" } deep-at ] unit-test
[ 1 ] [ H{ { "a" H{ { "b" 1 } } } } { "a" "b" } deep-at ] unit-test

USE: math.combinatorics

[
    H{
        { 0 V{ "" } }
        { 1 V{ "a" "b" "c" } }
        { 2 V{ "ab" "ac" "bc" } }
        { 3 V{ "abc" } }
    }
] [ "abc" all-subsets [ length ] group-by ] unit-test

USE: math.statistics

[ { { 1 3 } { "Other" 2 } } ]
[ { 1 1 1 2 2 } histogram 1 trim-histogram ] unit-test

[ { "negative" "zero" "positive" } ] [
    { -1 0 1 } [
        {
           { [ 0 > ] [ "positive" ] }
           { [ 0 < ] [ "negative" ] }
           [ "zero" ]
        } cond-case
    ] map
] unit-test

[ H{ } ] [ { } assoc-merge ] unit-test

[ H{ { "a" V{ 2 5 } } { "b" V{ 3 } } { "c" V{ 10 } } } ]
[
    { H{ { "a" 2 } { "b" 3 } } H{ { "a" 5 } { "c" 10 } } }
    assoc-merge
] unit-test

[ { "a" "b" "c" "d" "ab" "bc" "cd" "abc" "bcd" "abcd" } ] [
    "abcd" all-subseqs
] unit-test

[ "" ] [ "abc" "def" longest-subseq ] unit-test
[ "abcd" ] [ "abcd" "abcde" longest-subseq ] unit-test
[ "foo" ] [ "foo" "foobar" longest-subseq ] unit-test
[ "foo" ] [ "foobar" "foo" longest-subseq ] unit-test

[ "1" "123" ] [ "1" "123" [ length ] [ > ] swap-when ] unit-test
[ "123" "1" ] [ "1" "123" [ length ] [ < ] swap-when ] unit-test

[ { 0 1 0 1 } ] [
    { 0 0 0 0 } { 1 3 } over [ 1 + ] change-nths
] unit-test

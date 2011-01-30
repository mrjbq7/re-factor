
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

[ H{ { f V{ 2 2 2 } } { t V{ 1 3 1 } } } ]
[ { 1 2 3 1 2 2 } [ odd? ] group-by ] unit-test

USE: math.statistics

[ { { 1 3 } { "Other" 2 } } ]
[ { 1 1 1 2 2 } histogram 1 trim-histogram ] unit-test


USING: printf-example tools.test ;

IN: printf-example

[ "" ] [ "" sprintf ] unit-test
[ "asdf" ] [ "asdf" sprintf ] unit-test
[ "10" ] [ 10 "%d" sprintf ] unit-test
[ "-10" ] [ -10 "%d" sprintf ] unit-test
[ "ff" ] [ HEX: ff "%x" sprintf ] unit-test
[ "Hello, World!" ] [ "Hello, World!" "%s" sprintf ] unit-test
[ "printf test" ] [ "printf test" sprintf ] unit-test
[ "char a = 'a'" ] [ CHAR: a "char %c = 'a'" sprintf ] unit-test
[ "0 message(s)" ] [ 0 "message" "%d %s(s)" sprintf ] unit-test
[ "0 message(s) with %" ] [ 0 "message" "%d %s(s) with %%" sprintf ] unit-test
[ "There are 10 monkeys in the kitchen" ] [ 10 "kitchen" "There are %d monkeys in the %s" sprintf ] unit-test
[ "10%" ] [ 10 "%d%%" sprintf ] unit-test
[ "[monkey]" ] [ "monkey" "[%s]" sprintf ] unit-test


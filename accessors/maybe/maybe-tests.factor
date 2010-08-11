
USING: accessors accessors.maybe kernel tools.test ;

IN: accessors.maybe

<<
TUPLE: person name age ;
person define-maybe-accessors
>>

[ "Frank" ] [ person new [ "Frank" ] maybe-name ] unit-test
[ "Joe" ] [ "Joe" 20 person boa [ "Frank" ] maybe-name ] unit-test


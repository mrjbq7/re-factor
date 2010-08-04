
USING: arrays sequences text-or-binary tools.test ;

[ t ] [ "" text? ] unit-test
[ f ] [ "\0" text? ] unit-test
[ t ] [ "asdf" text? ] unit-test
[ f ] [ "\0asdf" text? ] unit-test

[ t ] [ 10 1 <array> 90 CHAR: A <array> append text? ] unit-test
[ f ] [ 20 1 <array> 80 CHAR: A <array> append text? ] unit-test


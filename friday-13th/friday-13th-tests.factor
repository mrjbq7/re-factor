
USING: friday-13th tools.test ;

IN: friday-13th

[ f ] [ 2012 1 01 <date> friday-13th? ] unit-test
[ t ] [ 2012 1 13 <date> friday-13th? ] unit-test
[ f ] [ 2012 2 13 <date> friday-13th? ] unit-test

[ t ] [
    500 2012 friday-13ths
] unit-test

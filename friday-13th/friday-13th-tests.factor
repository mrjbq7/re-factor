
USING: accessors assocs calendar friday-13th math.statistics
sequences tools.test ;

IN: friday-13th

[ f ] [ 2012 1 01 <date> friday-13th? ] unit-test
[ t ] [ 2012 1 13 <date> friday-13th? ] unit-test
[ f ] [ 2012 2 13 <date> friday-13th? ] unit-test

[ 3 ] [ 2012 friday-13ths length ] unit-test

[ 3 ] [
    500 2012 all-friday-13ths
    [ year>> ] collect-by >alist
    [ second length ] histogram-by
    assoc-size
] unit-test

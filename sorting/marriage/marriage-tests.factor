
USING: arrays kernel random sequences sorting sorting.marriage
sorting.marriage.private tools.test ;

IN: sorting.marriage

[ f ] [ 0 0 { } find-max ] unit-test
[ 0 ] [ 0 1 { 1 } find-max ] unit-test
[ 0 ] [ 0 1 { 1 2 } find-max ] unit-test
[ 1 ] [ 0 2 { 1 2 } find-max ] unit-test
[ 0 ] [ 0 3 { 3 2 1 } find-max ] unit-test
[ 1 ] [ 0 3 { 1 3 2 } find-max ] unit-test
[ 2 ] [ 0 3 { 1 2 3 } find-max ] unit-test

[ { } ] [ { } [ marriage-sort ] keep ] unit-test

[ { 0 1 2 3 4 5 6 7 8 9 } ]
[ 10 iota >array randomize [ marriage-sort ] keep ] unit-test

[ t ]
[
    100 [ random-32 ] replicate
    [ dup marriage-sort ] [ natural-sort ] bi =
] unit-test

[ t ]
[
    1000 [ random-32 ] replicate
    [ dup marriage-sort ] [ natural-sort ] bi =
] unit-test

[ t ]
[
    10000 [ random-32 ] replicate
    [ dup marriage-sort ] [ natural-sort ] bi =
] unit-test


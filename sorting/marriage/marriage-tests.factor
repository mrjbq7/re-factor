
USING: arrays kernel random sequences sorting sorting.marriage
tools.test ;

IN: sorting.marriage

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


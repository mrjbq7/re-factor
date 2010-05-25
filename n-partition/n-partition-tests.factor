USING: n-partition tools.test ;

IN: n-partition.tests

[ { 3 } ] [ 3 1 n-partition ] unit-test
[ { 1 1 1 } ] [ 3 3 n-partition ] unit-test
[ { 2 1 2 } ] [ 5 3 n-partition ] unit-test
[ { 1 0 1 0 1 } ] [ 3 5 n-partition ] unit-test
[ { 143 143 143 142 143 143 143 } ] [ 1000 7 n-partition ] unit-test


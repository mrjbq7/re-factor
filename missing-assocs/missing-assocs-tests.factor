USING: assocs kernel math sequences tools.test ;
IN: missing-assocs

{ 2 } [
    8 [ 2 * ] <missing-hash> 1 of
] unit-test

{ { { 1 V{ 2 } } { 2 V{ 4 } } } } [
    8 [ V{ } clone ] <default-hash>
    [ 1 [ of ] [ 2 * swap push ] bi ]
    [ 2 [ of ] [ 2 * swap push ] bi ]
    [ >alist ] tri
] unit-test

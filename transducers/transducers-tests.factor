USING: math math.primes sequences tools.test transducers ;

{ V{ 2 4 } } [
    { 1 2 3 4 5 6 7 }
    xcollect
    [ 5 > ] xuntil
    [ 1 + ] xmap
    [ odd? ] xfilter
    transduce
] unit-test

{ V{ 0 1 2 } } [
    10 <iota>
    xcollect
    3 xtake
    transduce
] unit-test

{ V{ 4 9 25 49 121 } } [
    100 <iota>
    xcollect
    5 xtake
    [ sq ] xmap
    [ prime? ] xfilter
    transduce
] unit-test

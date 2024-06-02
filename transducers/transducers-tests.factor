USING: math math.primes ranges sequences tools.test transducers ;

{ V{ 2 4 } } [
    { 1 2 3 4 5 6 7 } [
        [ odd? ] xfilter
        [ 1 + ] xmap
        [ 5 > ] xtake-until
        xcollect
    ] transduce
] unit-test

{ V{ 0 1 2 } } [
    10 <iota> [
        3 xtake
        xcollect
    ] transduce
] unit-test

{ V{ 3 4 5 6 7 8 9 } } [
    10 <iota> [
        3 xdrop
        xcollect
    ] transduce
] unit-test

{ V{ 4 9 25 49 121 } } [
    100 <iota> [
        [ prime? ] xfilter
        [ sq ] xmap
        5 xtake
        xcollect
    ] transduce
] unit-test

{ V{ 0 4 20 56 120 } } [
    10 [1..b) [
        [ even? ] xfilter
        [ sq ] xmap
        0 [ + ] xaccumulate
    ] transduce
] unit-test

{ V{ 1 1 2 6 24 120 720 5040 40320 362880 } } [
    10 [1..b) [
        1 [ * ] xaccumulate
    ] transduce
] unit-test

{ 328350 } [
    100 <iota> [
        [ sq ] xmap
        xsum
    ] transduce
] unit-test

{
    H{
        { 3 V{ "foo" "bar" "baz" } }
        { 6 V{ "apples" } }
        { 7 V{ "bananas" } }
    }
} [
    { "foo" "bar" "bananas" "baz" "apples" } [
        [ length ] xgroup-by
    ] transduce
] unit-test

{ "bananas" } [
    { "foo" "bar" "bananas" "baz" "apples" } [
        [ length 3 > ] xfind
    ] transduce
] unit-test

{ V{ V{ 0 1 2 } V{ 3 4 5 } V{ 6 7 8 } V{ 9 } } } [
    10 <iota> [
        3 xgroup
    ] transduce
] unit-test


{ V{ 1 2 3 4 } } [
    { 1 1 1 2 2 3 3 3 3 4 } [
        xdedupe
        xcollect
    ] transduce
] unit-test

{ V{ V{ { 0 1 } { 1 9 } { 2 25 } } V{ { 3 49 } { 4 81 } } } } [
    10 <iota> [
        [ even? ] xreject
        [ sq ] xmap
        xenumerate
        3 xgroup
    ] transduce
] unit-test

{ V{ V{ 0 1 2 } V{ 3 4 5 } V{ 6 7 8 } V{ 9 } } } [
    10 <iota> [
       [ 3 mod 0 = ] xsplit-when
    ] transduce
] unit-test

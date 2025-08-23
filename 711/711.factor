USING: backtrack combinators.short-circuit kernel locals math
math.combinatorics math.functions ranges sequences ;

IN: 711

! “A mathematician purchased four items in a grocery store. He
! noticed that when he added the prices of the four items, the
! sum came to $7.11, and when he multiplied the prices of the
! four items, the product came to $7.11.”

:: solve1 ( -- seq )
    0 0 0 0 :> ( w! x! y! z! )
    711 [ w!
        711 w - [ x!
            711 w - x - [ y!
                711 x - y - w - z!
                w x * y * z * 711,000,000 =
            ] find-integer
        ] find-integer
    ] find-integer [ { w x y z } ] [ f ] if ;

:: solve2 ( -- seq )
    711 <iota> amb-lazy :> w
    711 w - <iota> amb-lazy :> x
    711 w - x - <iota> amb-lazy :> y
    711 w - x - y - :> z

    w x * y * z * 711,000,000 = [ fail ] unless

    { w x y z } ;

:: solve3 ( -- seq )
    0.01 7.11 0.01 <range> amb-lazy :> w
    0.01 7.11 w - 0.01 <range> amb-lazy :> x
    0.01 7.11 w - x - 0.01 <range> amb-lazy :> y
    7.11 w - x - y - :> z

    w x * y * z * 7.11 0.00001 ~ [ fail ] unless

    { w x y z } ;

:: solve4 ( -- seq )
    [
        711 <iota> amb-lazy :> w
        711 w - <iota> amb-lazy :> x
        711 w - x - <iota> amb-lazy :> y
        711 w - x - y - :> z

        w x * y * z * 711,000,000 = [ fail ] unless

        { w x y z }
    ] bag-of ;

:: solve5 ( -- seq )
    1/100 711/100 1/100 <range> amb-lazy :> w
    1/100 711/100 w - 1/100 <range> amb-lazy :> x
    1/100 711/100 w - x - 1/100 <range> amb-lazy :> y
    711/100 w - x - y - :> z

    w x * y * z * 711/100 = [ fail ] unless

    { w x y z } ;

: solve6 ( -- seq )
    171 <iota> 4 [
        { [ sum 711,000,000 = ] [ product 711,000,000 = ] } 1&&
    ] find-combination ;

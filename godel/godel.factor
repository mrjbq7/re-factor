USING: ascii assocs kernel math math.functions math.primes
math.primes.factors sequences ;

IN: godel

: >gödel ( str -- n )
    [ length nprimes ] keep [ 64 - ^ ] 2map product ;

: gödel> ( n -- str )
    group-factors values [ 64 + ] "" map-as ;

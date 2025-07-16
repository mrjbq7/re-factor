USING: alien.c-types alien.data arrays combinators command-line
kernel kernel.private math math.parser math.private math.vectors
math.vectors.simd memory namespaces prettyprint random sequences
sequences.private specialized-arrays tools.time typed ;

IN: loops

:: loops-benchmark1 ( u -- )
    10,000 random :> r
    10,000 0 <array> :> a
    10,000 [| i |
        100,000 [| j |
            i a [ j u mod + ] change-nth
        ] each-integer
        i a [ r + ] change-nth
    ] each-integer r a nth . ;

:: loops-benchmark2 ( u -- )
    10,000 random :> r
    10,000 0 <array> :> a
    10,000 [| i |
        100,000 [| j |
            i a [ j u mod + ] change-nth-unsafe
        ] each-integer
        i a [ r + ] change-nth-unsafe
    ] each-integer r a nth-unsafe . ;

TYPED:: loops-benchmark3 ( u: integer -- )
    10,000 random :> r
    10,000 0 <array> :> a
    10,000 [| i |
        100,000 [| j |
            i a [ j u mod + ] change-nth-unsafe
        ] each-integer
        i a [ r + ] change-nth-unsafe
    ] each-integer r a nth-unsafe . ;

TYPED:: loops-benchmark4 ( u: fixnum -- )
    10,000 random { fixnum } declare :> r
    10,000 0 <array> :> a
    10,000 [| i |
        100,000 [| j |
            i a [ j u mod fixnum+fast ] change-nth-unsafe
        ] each-integer
        i a [ r fixnum+fast ] change-nth-unsafe
    ] each-integer r a nth-unsafe . ;

SPECIALIZED-ARRAY: uint32_t

TYPED:: loops-benchmark5 ( u: fixnum -- )
    10,000 random { fixnum } declare :> r
    10,000 uint32_t <c-array> :> a
    10,000 [| i |
        100,000 [| j |
            i a [ j u mod fixnum+fast ] change-nth-unsafe
        ] each-integer
        i a [ r fixnum+fast ] change-nth-unsafe
    ] each-integer r a nth-unsafe . ;

TYPED:: loops-benchmark6 ( u: fixnum -- )
    10,000 random { fixnum } declare :> r
    10,000 uint32_t <c-array> :> a
    10,000 [| i |
        100,000 <iota> [ u mod ] map-sum :> v
        i a [ v + ] change-nth
        i a [ r + ] change-nth
    ] each-integer r a nth . ;

TYPED:: loops-benchmark7 ( u: fixnum -- )
    10,000 random { fixnum } declare :> r
    10,000 uint32_t <c-array> :> a
    100,000 <iota> [ u mod ] map-sum :> v
    10,000 [| i |
        i a [ v fixnum+fast ] change-nth-unsafe
        i a [ r fixnum+fast ] change-nth-unsafe
    ] each-integer r a nth-unsafe . ;

TYPED:: loops-benchmark8 ( u: fixnum -- )
    10,000 random { fixnum } declare :> r
    10,000 uint32_t <c-array> :> a
    100,000 <iota> [ u mod ] map-sum :> v
    10,000 [| i |
        v r fixnum+fast i a set-nth-unsafe
    ] each-integer r a nth-unsafe . ;

TYPED:: loops-benchmark9 ( u: fixnum -- )
    10,000 random { fixnum } declare :> r
    100,000 <iota> [ u mod ] map-sum :> v
    v r + . ;

:: loops-benchmark10 ( u -- )
    10,000 random 100,000 <iota> [ u mod ] map-sum + . ;

: loops-benchmark11 ( u -- )
    drop 10,000 [ 100,000 [ ] times ] times ;

MAIN: [
    command-line get first string>number {
        [ gc [ loops-benchmark1 ] time ]
        [ gc [ loops-benchmark2 ] time ]
        [ gc [ loops-benchmark3 ] time ]
        [ gc [ loops-benchmark4 ] time ]
        [ gc [ loops-benchmark5 ] time ]
        [ gc [ loops-benchmark6 ] time ]
        [ gc [ loops-benchmark7 ] time ]
        [ gc [ loops-benchmark8 ] time ]
        [ gc [ loops-benchmark9 ] time ]
        [ gc [ loops-benchmark10 ] time ]
        [ gc [ loops-benchmark11 ] time ]
    } cleave
]

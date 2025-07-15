USING: arrays combinators command-line kernel.private math
math.parser math.private memory namespaces prettyprint random
sequences sequences.private tools.time typed ;

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

MAIN: [
    command-line get first string>number {
        [ gc [ loops-benchmark1 ] time ]
        [ gc [ loops-benchmark2 ] time ]
        [ gc [ loops-benchmark3 ] time ]
        [ gc [ loops-benchmark4 ] time ]
    } cleave
]

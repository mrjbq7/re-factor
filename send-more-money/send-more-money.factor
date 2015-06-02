! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: backtrack continuations fry formatting kernel locals
math math.functions sequences sets ;

IN: send-more-money

CONSTANT: digits { 0 1 2 3 4 5 6 7 8 9 }

: >number ( seq -- n ) 0 [ [ 10 * ] dip + ] reduce ;

:: send-more-money ( -- )
    [
        digits { 0 } diff amb-lazy :> s
        digits { s } diff amb-lazy :> e
        digits { s e } diff amb-lazy :> n
        digits { s e n } diff amb-lazy :> d
        { s e n d } >number :> send

        digits { 0 s e n d } diff amb-lazy :> m
        digits { s e n d m } diff amb-lazy :> o
        digits { s e n d m o } diff amb-lazy :> r
        { m o r e } >number :> more

        digits { s e n d m o r } diff amb-lazy :> y
        { m o n e y } >number :> money

        send more + money = [
            send more money "   %s\n+  %s\n= %s\n" printf
        ] when

    ] amb-all ;

: each-digit ( except quot -- )
    '[ digits _ diff _ each ] call ; inline

:: send-more-money2 ( -- )
    { 0 } [| s |
        { s } [| e |
            { s e } [| n |
                { s e n } [| d |
                    { s e n d } >number :> send
                    { 0 s e n d } [| m |
                        { s e n d m } [| o |
                            { s e n d m o } [| r |
                                { m o r e } >number :> more
                                { s e n d m o r } [| y |
                                    { m o n e y } >number :> money
                                    send more + money = [
                                        send more money
                                        "   %s\n+  %s\n= %s\n" printf
                                    ] when
                                ] each-digit
                            ] each-digit
                        ] each-digit
                    ] each-digit
                ] each-digit
            ] each-digit
        ] each-digit
    ] each-digit ;

:: send-more-money3 ( -- )
    [
        { 0 } [| s |
            { s } [| e |
                { s e } [| n |
                    { s e n } [| d |
                        { s e n d } >number :> send
                        { 0 s e n d } [| m |
                            { s e n d m } [| o |
                                { s e n d m o } [| r |
                                    { m o r e } >number :> more
                                    { s e n d m o r } [| y |
                                        { m o n e y } >number :> money
                                        send more + money = [
                                            send more money
                                            "   %s\n+  %s\n= %s\n" printf
                                            return
                                        ] when
                                    ] each-digit
                                ] each-digit
                            ] each-digit
                        ] each-digit
                    ] each-digit
                ] each-digit
            ] each-digit
        ] each-digit
    ] with-return ;

:: send-more-money4 ( -- )
    [
        digits { 0 } diff amb-lazy :> s
        digits { s } diff amb-lazy :> e
        digits { s e } diff amb-lazy :> n
        digits { s e n } diff amb-lazy :> d
        { s e n d } >number

        digits { 0 s e n d } diff amb-lazy :> m
        digits { s e n d m } diff amb-lazy :> o
        digits { s e n d m o } diff amb-lazy :> r
        { m o r e } >number

        digits { s e n d m o r } diff amb-lazy :> y
        { m o n e y } >number

        3dup [ + ] [ = ] bi*

    ] [ f f f ] if-amb drop "   %s\n+  %s\n= %s\n" printf ;

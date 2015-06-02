! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: backtrack formatting kernel locals math math.functions
sequences sets ;

IN: send-more-money

CONSTANT: digits { 0 1 2 3 4 5 6 7 8 9 }

: >number ( seq -- n ) 0 [ [ 10 * ] dip + ] reduce ;

:: solve ( -- send more money )
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

    ] [ f f f ] if-amb drop ;

: solve. ( -- )
    solve "   %s\n+  %s\n= %s\n" printf ;

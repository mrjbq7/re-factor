! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: backtrack formatting kernel locals math math.functions
sequences sets ;

IN: send-more-money

CONSTANT: digits { 0 1 2 3 4 5 6 7 8 9 }

: >number ( seq -- n ) 0 [ [ 10 * ] dip + ] reduce ;

:: send-more-money ( -- )
    [
        digits { 0 } diff amb-lazy :> s
        digits { s } diff amb-lazy :> e
        digits { s e } diff amb-lazy :> n
        digits { s e n } diff amb-lazy :> d
        digits { 0 s e n d } diff amb-lazy :> m
        digits { s e n d m } diff amb-lazy :> o
        digits { s e n d m o } diff amb-lazy :> r
        digits { s e n d m o r } diff amb-lazy :> y

        { s e n d } { m o r e } { m o n e y }
        [ >number ] tri@ 3dup :> ( send more money )

        send more + money =

    ] [ f f f ] if-amb drop "   %s\n+  %s\n= %s\n" printf ;

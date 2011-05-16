! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals math math.parser memoize sequences ;

IN: fast-fib

MEMO: slow-fib ( m -- n )
    dup 0 >= [ throw ] unless
    dup 2 >= [
        [ 2 - slow-fib ] [ 1 - slow-fib ] bi +
    ] when ;

: okay-fib ( m -- n )
    dup 0 >= [ throw ] unless
    [ 0 1 ] dip [ [ + ] [ drop ] 2bi ] times drop ;

! http://bosker.wordpress.com/2011/04/29/the-worst-algorithm-in-the-world/
! http://gmplib.org/manual/Fibonacci-Numbers-Algorithm.html

:: fast-fib ( m -- n )
    m 0 >= [ m throw ] unless
    m 2 >base [ CHAR: 1 = ] { } map-as :> bits
    1 :> a! 0 :> b! 1 :> c!
    bits [
        [
            a c + b *
            b sq c sq +
        ] [
            a sq b sq +
            a c + b *
        ] if b! a! a b + c!
    ] each b ;

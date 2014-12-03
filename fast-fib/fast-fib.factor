! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators kernel locals math math.matrices math.parser
memoize sequences ;

IN: fast-fib

MEMO: (slow-fib) ( m -- n )
    dup 2 >= [
        [ 2 - (slow-fib) ] [ 1 - (slow-fib) ] bi +
    ] when ;

: slow-fib ( m -- n )
    dup 0 >= [ throw ] unless (slow-fib) ;

: okay-fib ( m -- n )
    dup 0 >= [ throw ] unless
    [ 0 1 ] dip [ [ + ] [ drop ] 2bi ] times drop ;

! http://bosker.wordpress.com/2011/04/29/the-worst-algorithm-in-the-world/
! http://gmplib.org/manual/Fibonacci-Numbers-Algorithm.html

:: fast-fib ( m -- n )
    m 0 >= [ m throw ] unless
    m 2 >base [ CHAR: 1 = ] { } map-as :> bits
    1 0 1 bits [| a b c bit |
        bit [
            a c + b *
            b sq c sq +
        ] [
            a sq b sq +
            a c + b *
        ] if 2dup +
    ] each drop nip ;

MEMO: (faster-fib) ( m -- n )
    dup 1 > [
        [ 2/ dup 1 - [ (faster-fib) ] bi@ ] [ 4 mod ] bi {
            { 1 [ [ 2 * ] dip [ + ] [ - ] 2bi * 2 + ] }
            { 3 [ [ 2 * ] dip [ + ] [ - ] 2bi * 2 - ] }
            [ drop dupd 2 * + * ]
        } case
    ] when ;

: faster-fib ( m -- n )
    dup 0 >= [ throw ] unless (faster-fib) ;

MEMO: (slow-trib) ( m -- n )
    dup 3 < [ 0 = 0 1 ? ] [
        [ 3 - (slow-trib) ]
        [ 2 - (slow-trib) ]
        [ 1 - (slow-trib) ] tri + +
    ] if ;

: slow-trib ( m -- n )
    dup 0 >= [ throw ] unless (slow-trib) ;

: okay-trib ( m -- n )
    dup 0 >= [ throw ] unless
    [ 0 0 1 ] dip [ [ + + ] [ drop ] 3bi ] times 2drop ;

: fast-trib ( m -- n )
    { { 1 1 0 } { 1 0 1 } { 1 0 0 } } swap m^n first second ;

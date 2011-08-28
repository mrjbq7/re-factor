! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel literals math math.functions math.ranges memoize
sequences sequences.private typed ;

IN: pow

TYPED: float>parts ( x: float -- float: float int: fixnum )
    dup >fixnum [ - ] keep ; inline

CONSTANT: BITS1 10
CONSTANT: BITS2 $[ BITS1 2 * ]
CONSTANT: BITS3 $[ BITS1 3 * ]

CONSTANT: PRECISION1 $[ 1 BITS1 shift ]
CONSTANT: PRECISION2 $[ 1 BITS2 shift ]
CONSTANT: PRECISION3 $[ 1 BITS3 shift ]

CONSTANT: MASK $[ PRECISION1 1 - ]

CONSTANT: FRAC1 $[ 2 PRECISION1 iota [ PRECISION1 / ^ ] with map ]
CONSTANT: FRAC2 $[ 2 PRECISION1 iota [ PRECISION2 / ^ ] with map ]
CONSTANT: FRAC3 $[ 2 PRECISION1 iota [ PRECISION3 / ^ ] with map ]

! a ^ ( b + c ) == a ^ b * a ^ c
! a = 2
! b = int(a)   // integer part
! c = frac(a)  // fractional part

: compute-parts ( n -- 2^int frac )
    [ float>parts ] keep 0 >= [ 1 swap shift ] [
        over 0 < [ [ 1 + ] [ 1 - ] bi* ] when
        [ 1.0 1 ] dip neg shift /
    ] if swap ; inline

: cache-index ( frac -- index )
    PRECISION3 * >fixnum ; inline

: cache-lookup ( 2^int index -- 2^n )
    [ BITS2 neg shift FRAC1 nth-unsafe ]
    [ BITS1 neg shift MASK bitand FRAC2 nth-unsafe ]
    [ MASK bitand FRAC3 nth-unsafe ] tri * * * ; inline

TYPED: pow2 ( n: float -- 2^n: float )
    compute-parts cache-index cache-lookup ;

! "orig" print [ 1000000 [ 2 16.3 ^ drop ] times ] time
! "pow2" print [ 1000000 [ 16.3 pow2 drop ] times ] time




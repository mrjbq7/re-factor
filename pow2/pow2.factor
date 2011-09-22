! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel literals math math.functions sequences
sequences.private ;

IN: pow2

: float>parts ( x -- float int )
    dup >integer [ - ] keep ; inline

<<
CONSTANT: BITS1 10
>>

<<
CONSTANT: BITS2 $[ BITS1 2 * ]
CONSTANT: BITS3 $[ BITS1 3 * ]
>>

<<
CONSTANT: PRECISION1 $[ 1 BITS1 shift ]
CONSTANT: PRECISION2 $[ 1 BITS2 shift ]
CONSTANT: PRECISION3 $[ 1 BITS3 shift ]
>>

<<
CONSTANT: MASK $[ PRECISION1 1 - ]

CONSTANT: FRAC1 $[ 2 PRECISION1 iota [ PRECISION1 / ^ ] with map ]
CONSTANT: FRAC2 $[ 2 PRECISION1 iota [ PRECISION2 / ^ ] with map ]
CONSTANT: FRAC3 $[ 2 PRECISION1 iota [ PRECISION3 / ^ ] with map ]
>>

! a ^ ( b + c ) == a ^ b * a ^ c
! a = 2
! b = int(a)   // integer part
! c = frac(a)  // fractional part

: 2^int ( n -- 2^int frac )
    [ float>parts ] keep 0 >= [ 1 swap shift ] [
        over 0 < [ [ 1 + ] [ 1 - ] bi* ] when
        1 swap neg shift 1.0 swap /
    ] if swap ; inline

: 2^frac ( frac -- 2^frac )
    PRECISION3 * >fixnum
    [ BITS2 neg shift FRAC1 nth-unsafe ]
    [ BITS1 neg shift MASK bitand FRAC2 nth-unsafe ]
    [ MASK bitand FRAC3 nth-unsafe ] tri * * ; inline

: pow2 ( n -- 2^n )
    >float 2^int 2^frac * >float ;

! "orig" print [ 1000000 [ 2 16.3 ^ drop ] times ] time
! "pow2" print [ 1000000 [ 16.3 pow2 drop ] times ] time

USE: random
USE: tools.time

: pow2-seq ( n -- seq )
    [ -20 20 uniform-random-float ] replicate ;

: pow2-test ( seq -- new old )
    [ [ pow2 drop ] [ each ] benchmark ]
    [ 2 swap [ ^ drop ] with [ each ] benchmark ] bi ;

: fast-pow ( a b -- a^b )
    [ double>bits -32 shift 1072632447 - ]
    [ * 1072632447 + >integer 32 shift bits>double ] bi* ;

: fast-exp ( x -- e^x )
    1512775 * 1072693248 60801 - + 32 shift bits>double ;

: fast-ln ( x -- y )
    double>bits -32 shift 1072632447 - 1512775 / ;

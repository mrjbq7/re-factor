! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs binary-search
combinators.short-circuit formatting fry kernel
io.streams.string literals locals math math.bits math.bitwise
math.functions memoize quotations random sequences sets
splitting system typed wolfram-alpha ;

IN: power-of-2

<<
CONSTANT: POWERS-OF-2 $[ 64 <iota> [ 2^ ] map ]
>>

: check-all/power-of-2? ( n -- ? )
    POWERS-OF-2 member? ;

: binary-search/power-of-2? ( n -- ? )
    POWERS-OF-2 sorted-member? ;

: linear-search/power-of-2? ( n -- ? )
    POWERS-OF-2 over [ >= ] curry find nip = ;

: hash-search/power-of-2? ( n -- ? )
    $[ POWERS-OF-2 fast-set ] in? ;

: log-search/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ dup log2 POWERS-OF-2 nth = ] if ;

: wolfram/power-of-2? ( n -- ? )
    "is log2(%d) an integer?" sprintf
    [ wolfram-text. ] with-string-writer "True" subseq? ;

: shift-right/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ [ dup even? ] [ 2/ ] while 1 = ] if ;

: bit-count/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ bit-count 1 = ] if ;

: bits/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ make-bits [ t? ] count 1 = ] if ;

: sqrt/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [
        { [ dup sqrt floor sq number= ] [ 2 = ] } 1||
    ] if ;

: log2/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ dup log2 2^ = ] if ;

: next-power/power-of-2? ( n -- ? )
    dup 1 = [ drop t ] [ dup next-power-of-2 = ] if ;

: complement/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ dup dup neg bitand = ] if ;

: decrement/power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ dup 1 - bitand zero? ] if ;

TYPED: decrement+typed/power-of-2? ( n: fixnum -- ? )
    dup 0 <= [ drop f ] [ dup 1 - bitand zero? ] if ;

: decrement+short/power-of-2? ( n -- ? )
    { [ dup 1 - bitand zero? ] [ 0 > ] } 1&& ;

:: decrement+short+locals/power-of-2? ( n -- ? )
    { [ n n 1 - bitand zero? ] [ n 0 > ] } 0&& ;

TYPED: decrement+short+typed/power-of-2? ( n: fixnum -- ? )
    { [ dup 1 - bitand zero? ] [ 0 > ] } 1&& ;

USING: alien alien.c-types alien.syntax alien.libraries ;
"libpowerof2" "power-of-2.dylib" cdecl add-library
LIBRARY: libpowerof2
FUNCTION: int isPowerOfTwo ( int x )

: alien/power-of-2? ( n -- ? )
    isPowerOfTwo 1 = ;

<PRIVATE

CONSTANT: IMPLEMENTATIONS {
    alien/power-of-2?
    check-all/power-of-2?
    linear-search/power-of-2?
    binary-search/power-of-2?
    hash-search/power-of-2?
    log-search/power-of-2?
    ! wolfram/power-of-2?
    shift-right/power-of-2?
    bit-count/power-of-2?
    bits/power-of-2?
    sqrt/power-of-2?
    log2/power-of-2?
    next-power/power-of-2?
    complement/power-of-2?
    decrement/power-of-2?
    decrement+short/power-of-2?
    decrement+short+locals/power-of-2?
    decrement+typed/power-of-2?
    decrement+short+typed/power-of-2?
}

PRIVATE>

: test-power-of-2 ( -- ? )
    IMPLEMENTATIONS [
        1quotation [ call( n -- ? ) ] curry
        [ {  1 2 4 1024 } swap all? ]
        [ { -1 0 3 1025 } swap any? not ] bi and
    ] all? ;

: bench-power-of-2 ( -- assoc )
    IMPLEMENTATIONS randomize 20 2^ [ random-32 ] replicate '[
        [ name>> "/" split1 drop ] [
            1quotation [ drop ] compose
            [ each ] curry [ _ ] prepose
            nano-count [ call( -- ) nano-count ] dip -
        ] bi
    ] { } map>assoc ;

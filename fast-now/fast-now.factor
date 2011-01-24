! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: calendar kernel math namespaces system ;

IN: fast-now

<PRIVATE

CONSTANT: cache-duration 1000000

SYMBOL: cache-value
SYMBOL: cache-until

: cache-expired? ( nanos -- ? )
    cache-until get-global 0 or > ;

: reset-cache ( nanos -- )
    cache-duration + cache-until set-global ;

: update-cache ( nanos -- timestamp )
    reset-cache now [ cache-value set-global ] keep ;

PRIVATE>

: fast-now ( -- timestamp )
    nano-count dup cache-expired? [ update-cache ] [
        drop cache-value get-global
    ] if ;

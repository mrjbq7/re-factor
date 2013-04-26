! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.data kernel locals math sequences
specialized-arrays ta-lib.ffi ;

SPECIALIZED-ARRAY: double

IN: ta-lib

<PRIVATE

ERROR: ta-error n ;

: check-error ( retcode -- )
    [ ta-error ] unless-zero ;

PRIVATE>

:: MOM ( seq n -- seq' )
    0 seq length 1 - seq double >c-array n
    0 int <ref> 0 int <ref>
    seq length <double-array>
    [ TA_MOM check-error ] keep ;

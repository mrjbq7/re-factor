! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii combinators.short-circuit kernel math.order
sequences splitting ;

IN: n-numbers

! may not begin with zero (0).
! may not be the letters "I" or "O" to avoid confusion
! with the numbers one (1) or zero (0).
: (n-number?) ( digits letters -- ? )
    [ dup first CHAR: 0 = [ drop f ] [ [ digit? ] all? ] if ]
    [ [ [ Letter? ] [ "IiOo" member? not ] bi and ] all? ]
    bi* and ;

! may be one (1) to five (5) numbers (e.g. N12345);
! may be one (1) to four (4) numbers and one (1) suffix letter
! (examples: N1A and N1234Z);
! may be one (1) to three (3) numbers and two (2) suffix letters
! (examples: N24BY and N123AZ).
: n-number? ( str -- ? )
    "N" ?head drop {
        [ { [ length 1 5 between? ] [ f (n-number?) ] } 1&& ]
        [ { [ length 2 5 between? ] [ 1 cut* (n-number?) ] } 1&& ]
        [ { [ length 3 5 between? ] [ 2 cut* (n-number?) ] } 1&& ]
    } 1|| ;

! Registration numbers N1 through N99 are reserved for Federal
! Aviation Administration (FAA) internal use and are not
! available.
: reserved? ( str -- ? )
    "N" ?head drop
    { [ length 1 2 between? ] [ [ digit? ] all? ] } 1&& ;

H{
    { CHAR: A "4" }
    { CHAR: B "86" }
    { CHAR: E "3" }
    { CHAR: 6 "69" }
    { CHAR: I "1" }
    { CHAR: J "1" }
    { CHAR: L "17" }
    { CHAR: O "0" }
    { CHAR: P "9" }
    { CHAR: Q "92" }
    { CHAR: S "52" }
    { CHAR: T "7" }
    { CHAR: Y "7" }
    { CHAR: 2 "Z" }
} drop

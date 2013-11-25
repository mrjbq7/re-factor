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
        [ [ length 1 5 between? ] [ f (n-number?) ] bi and ]
        [ [ length 2 5 between? ] [ 1 cut* (n-number?) ] bi and ]
        [ [ length 3 5 between? ] [ 2 cut* (n-number?) ] bi and ]
    } 1|| ;

! Registration numbers N1 through N99 are reserved for Federal
! Aviation Administration (FAA) internal use and are not
! available.
: reserved? ( str -- ? )
    "N" ?head drop
    { [ length 1 2 between? ] [ [ digit? ] all? ] } 1&& ;

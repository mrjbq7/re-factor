! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.combinatorics math.vectors sequences
sets ;

IN: square

: square? ( seq -- ? )
    members [ length 4 = ] [
        2 [ first2 distance ] map-combinations
        { 0 } diff length 2 =
    ] bi and ;

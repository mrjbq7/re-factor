! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math math.functions math.ranges math.vectors
sequences sets ;

IN: factors

: factor? ( m n -- ? )
    mod zero? ;

: factors ( n -- seq )
    dup [1,b] [ factor? ] with filter ;

: factors' ( n -- seq )
    dup sqrt ceiling >integer factors
    [ n/v ] keep append members ;

: check-factors ( n quot: ( m n -- ? ) -- ? )
    [ [ factors sum ] [ - ] ] dip tri ; inline

: perfect? ( n -- ? ) [ = ] check-factors ;

: abundant? ( n -- ? ) [ > ] check-factors ;

: deficient? ( n -- ? ) [ < ] check-factors ;

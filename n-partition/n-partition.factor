! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs kernel grouping sequences shuffle
math math.functions math.ranges math.statistics math.vectors ;

IN: n-partition

<PRIVATE

: percentages ( n -- seq ) [ [1,b] ] keep v/n ;

: steps ( x n -- seq ) percentages n*v ;

: rounded ( seq -- seq' ) [ round ] map ;

: differences ( seq -- seq' ) dup 0 prefix v- ;

PRIVATE>

: n-partition ( x n -- seq ) steps rounded differences ;

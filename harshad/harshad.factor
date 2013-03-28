! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: fry kernel math math.functions sequences ;

IN: harshad

! http://mathworld.wolfram.com/HarshadNumber.html

: sum-digits ( n -- x )
    0 swap [ dup zero? ] [ 10 /mod swap [ + ] dip ] until drop ;

: next-harshad ( n -- n' )
    [ dup dup sum-digits divisor? ] [ 1 + ] until ;

: harshad-between ( low high -- seq )
    [ next-harshad ] dip
    '[ dup _ <= ] [ [ 1 + next-harshad ] keep ] produce nip ;

: harshad-upto ( n -- seq )
    1 swap harshad-between ;

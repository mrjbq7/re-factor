! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals math math.functions math.ranges
sequences sorting.insertion ;

IN: sorting.marriage

<PRIVATE

! FIXME: Add sorting quot: ( elt -- elt' )
! FIXME: Use [ <=> ] from math.order (like natural-sort)
! FIXME: Implement find-max using <slice>, each-integer?

:: find-max ( from to seq -- i )
    from to >= [ f ] [
        from from 1 + [ dup to < ] [
            2dup [ seq nth ] bi@ < [ nip dup ] when 1 +
        ] while drop
    ] if ;

:: (marriage-sort) ( seq end skip -- seq end' )
    0 skip seq find-max
    skip end [ 2dup < ] [
        [ 2dup [ seq nth ] bi@ <= ] dip swap
        [ 1 - [ seq exchange ] 2keep ] [ [ 1 + ] dip ] if
    ] while nip 1 - [ seq exchange seq ] keep ;

PRIVATE>

: marriage-sort ( seq -- )
    dup length
    [ dup sqrt 1 - >fixnum dup 0 > ]
    [ (marriage-sort) ] while
    2drop [ ] insertion-sort ;



! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators fry hash-sets hashtables kernel
locals math math.parser sequences sets utils vectors ;

IN: ant

: sum-digits ( n -- x )
    0 swap [ dup zero? ] [ 10 /mod swap [ + ] dip ] until drop ;

USE: alien.c-types
USE: classes.struct

STRUCT: point { x uint } { y uint } ;
: <point> ( x y -- point ) point <struct-boa> ; inline

! FIXME: this makes it 430 times slower
! TUPLE: point x y ;
! C: <point> point

: walkable? ( point -- ? )
    [ x>> ] [ y>> ] bi [ sum-digits ] bi@ + 25 <= ; inline

:: ant ( -- total )
    ! HS{ } clone :> seen
    ! V{ } clone :> stack
    200000 <hash-set> :> seen
    100000 <vector> :> stack
    0 :> total!

    1000 1000 <point> stack push

    [ stack empty? ] [
        stack pop :> p
        p seen in? [
            p seen adjoin
            p walkable? [
                total 1 + total!
                p clone [ 1 + ] change-x stack push
                p clone [ 1 - ] change-x stack push
                p clone [ 1 + ] change-y stack push
                p clone [ 1 - ] change-y stack push
            ] when
        ] unless
    ] until total ;

: walk ( stack point -- stack' )
    {
        [ clone [ 1 + ] change-x over push ]
        [ clone [ 1 - ] change-x over push ]
        [ clone [ 1 + ] change-y over push ]
        [ clone [ 1 - ] change-y over push ]
    } cleave ;

: ?walk ( total stack point -- total stack )
    dup walkable? [ walk [ 1 + ] dip ] [ drop ] if ;

: (ant) ( total stack seen -- total' )
    '[ dup pop _ ?adjoin [ ?walk ] when* ] until-empty ;

: ant-no-locals ( -- total )
    0
    100000 <vector>
    200000 <hash-set>
    1000 1000 <point> pick push
    (ant) ;

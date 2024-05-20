! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math sequences ;

IN: transducers

: xapply ( reduce-quot quot: ( elt -- newelt ) -- reduce-quot' )
    '[ @ [ _ unless ] keep ] ; inline

: xcollect-into ( -- reduce-quot )
    [ suffix! f ] ; inline

: xcollect ( -- identity reduce-quot )
    V{ } clone xcollect-into ; inline

: xfilter ( reduce-quot quot: ( elt -- ? ) -- reduce-quot' )
    swap '[ dup @ _ [ drop f ] if ] ; inline

: xreject ( reduce-quot quot: ( elt -- ? ) -- reduce-quot' )
    negate xfilter ; inline

: xmap ( reduce-quot quot: ( elt -- newelt ) -- reduce-quot' )
    swap compose ; inline

: xuntil ( reduce-quot quot: ( elt -- ? ) -- reduce-quot' )
    swap '[ dup @ [ drop t ] _ if ] ; inline

: xwhile ( reduce-quot quot: ( elt -- ? ) -- reduce-quot' )
    negate xuntil ; inline

: xtake ( reduce-quot n -- reduce-quot )
    [ { 0 } clone ] 2dip swap '[
        0 _ [ 1 + dup ] change-nth _ <= _ [ drop f ] if
    ] ; inline

: xdrop ( reduce-quot n -- reduce-quot )
    [ { 0 } clone ] 2dip swap '[
        0 _ [ 1 + dup ] change-nth _ <= [ drop f ] _ if
    ] ; inline

: transduce ( ... seq identity reduce-quot: ( ... prev elt -- ... next stop? ) -- ... result )
    swapd find 2drop ; inline

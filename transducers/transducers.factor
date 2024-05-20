! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math prettyprint sequences ;

IN: transducers

! a "transducer" is defined as a quotation with a stack effect
! of ( ... prev elt -- ... next stop? )

! traditional transducers have init, step, and completion slots

! some questions about how/when to create the identity, whether
! the implementations should be backwards, or forwards, and
! whether the element that the stop value is triggered on
! should not be acted on...

: xreduce ( quot: ( prev elt -- next ) -- reduce-quot )
    [ f ] compose ; inline

: xapply ( reduce-quot quot: ( elt -- newelt ) -- reduce-quot' )
    '[ @ [ _ unless ] keep ] ; inline

: xcat ( reduce-quot -- reduce-quot' )
    '[ dup . @ ] ; inline

: xbreak ( reduce-quot -- reduce-quot' )
    [ B ] prepose ; inline

: xsum ( -- identity reduce-quot )
    0 [ + ] xreduce ; inline

: xproduct ( -- identity reduce-quot )
    1 [ * ] xreduce ; inline

: xaccumulate-into ( -- reduce-quot )
    [ over ?last 0 or + suffix! ] xreduce ; inline

: xaccumulate ( -- identity reduce-quot )
    V{ } clone xaccumulate-into ; inline

: xcollect-into ( -- reduce-quot )
    [ suffix! ] xreduce ; inline

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

: xtake ( reduce-quot n -- reduce-quot' )
    [ { 0 } clone ] 2dip swap '[
        0 _ [ 1 + dup ] change-nth _ <= _ [ drop t ] if
    ] ; inline

: xdrop ( reduce-quot n -- reduce-quot' )
    [ { 0 } clone ] 2dip swap '[
        0 _ [ 1 + dup ] change-nth _ <= [ drop f ] _ if
    ] ; inline

: transduce ( ... seq identity reduce-quot: ( ... prev elt -- ... next stop? ) -- ... result )
    swapd find 2drop ; inline

! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs kernel math prettyprint sequences ;

IN: transducers

! a "transducer" is defined as a quotation with a stack effect
! of ( ... prev elt -- ... next stop? )

! traditional transducers have init, step, and completion slots

! some questions about how/when to create the identity, whether
! the implementations should be backwards, or forwards, and
! whether the element that the stop value is triggered on
! should not be acted on...

: xreduce ( quot: ( prev elt -- next ) -- transducer )
    [ f ] compose ; inline

: xapply ( transducer quot: ( elt -- newelt ) -- transducer' )
    '[ @ [ _ unless ] keep ] ; inline

: xcat ( transducer -- transducer' )
    '[ dup . @ ] ; inline

: xbreak ( transducer -- transducer' )
    [ B ] prepose ; inline

: xcount ( -- identity transducer )
    0 [ [ 1 + ] when ] xreduce ; inline

: xsum ( -- identity transducer )
    0 [ + ] xreduce ; inline

: xproduct ( -- identity transducer )
    1 [ * ] xreduce ; inline

: xhistogram-into ( -- transducer )
    [ over inc-at ] xreduce ; inline

: xhistogram ( -- identity transducer )
    H{ } clone xhistogram-into ; inline

: xgroup-by ( quot: ( elt -- key ) -- transducer )
    '[ _ keep swap pick push-at ] xreduce ; inline

: xaccumulate-into ( -- transducer )
    [ over ?last 0 or + suffix! ] xreduce ; inline

: xaccumulate ( -- identity transducer )
    V{ } clone xaccumulate-into ; inline

: xcollect-into ( -- transducer )
    [ suffix! ] xreduce ; inline

: xcollect ( -- identity transducer )
    V{ } clone xcollect-into ; inline

: xfilter ( transducer quot: ( elt -- ? ) -- transducer' )
    swap '[ dup @ _ [ drop f ] if ] ; inline

: xreject ( transducer quot: ( elt -- ? ) -- transducer' )
    negate xfilter ; inline

: xmap ( transducer quot: ( elt -- newelt ) -- transducer' )
    swap compose ; inline

: xuntil ( transducer quot: ( elt -- ? ) -- transducer' )
    swap '[ dup @ [ drop t ] _ if ] ; inline

: xwhile ( transducer quot: ( elt -- ? ) -- transducer' )
    negate xuntil ; inline

: xtake ( transducer n -- transducer' )
    [ { 0 } clone ] 2dip swap '[
        0 _ [ 1 + dup ] change-nth _ <= _ [ drop t ] if
    ] ; inline

: xdrop ( transducer n -- transducer' )
    [ { 0 } clone ] 2dip swap '[
        0 _ [ 1 + dup ] change-nth _ <= [ drop f ] _ if
    ] ; inline

: transduce ( ... seq identity transducer: ( ... prev elt -- ... next stop? ) -- ... result )
    swapd find 2drop ; inline

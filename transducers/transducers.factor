! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators.short-circuit kernel
math prettyprint random sequences vectors ;

IN: transducers

! reducing function
! rf: ( prev elt -- next )

! transducing function
! xf: ( prev elt -- next )
! if elt is null, skip applying the xf
! if next is reduced, early exit
! if next is null, keep previous result

TUPLE: reduced obj ;

C: <reduced> reduced

: (transduce) ( ... seq identity xf: ( ... prev elt -- ... next ) -- ... result )
    swapd '[
        _ keepd over null eq? [ nip f ] [ drop dup reduced? ] if
    ] find 2drop dup reduced? [ obj>> ] when ; inline

: transduce ( seq quot: ( xf -- xf' ) -- result )
    [ null [ nip ] ] dip call (transduce) ; inline

: xf ( rf: ( prev elt -- next ) -- xf )
    '[ { [ over reduced? ] [ dup null eq? ] } 0|| [ drop ] _ if ] ;

: xmap ( xf quot: ( elt -- newelt ) -- xf' )
    '[ @ dup { [ reduced? ] [ null eq? ] } 1|| _ unless ] xf ;

: xfind ( xf quot: ( elt -- ? ) -- xf' )
    '[ dup @ [ <reduced> ] when ] xmap ; inline

: xpprint ( xf -- xf' )
    [ dup . ] xmap ; inline

: xbreak ( xf -- xf' )
    [ B ] xmap ; inline

: xcount-from ( xf n -- xf' )
    [let :> n! [ [ n 1 + n! ] when n ] xmap ] ; inline

: xcount ( xf -- xf' )
    0 xcount-from ;

: xsum ( xf -- xf' )
    [let 0 :> n! [ n + n! n ] xmap ] ; inline

: xproduct ( xf -- xf' )
    [let 1 :> n! [ n * n! n ] xmap ] ; inline

: xhistogram-into ( xf assoc -- xf' )
    '[ _ [ inc-at ] keep ] xmap ; inline

: xhistogram ( xf -- xf' )
    H{ } clone xhistogram-into ; inline

: xcollect-into ( xf growable -- xf' )
    '[ _ [ push ] keep ] xmap ; inline

: xcollect ( xf -- xf' )
    V{ } clone xcollect-into ; inline

: xgroup-by-into ( xf quot: ( elt -- key ) assoc -- xf' )
    '[ _ keep swap _ [ push-at ] keep ] xmap ; inline

: xgroup-by ( xf quot: ( elt -- key ) -- xf' )
    H{ } clone xgroup-by-into ; inline

: xdedupe-when ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    [let null :> prior!
        '[ prior over @ [ drop null ] [ dup prior! ] if ] xmap
    ] ; inline

: xdedupe-eq ( xf -- xf' ) [ eq? ] xdedupe-when ;

: xdedupe ( xf -- xf' ) [ = ] xdedupe-when ;

: xfilter ( xf quot: ( elt -- ? ) -- xf' )
    '[ dup @ [ drop null ] unless ] xmap ; inline

: xreject ( xf quot: ( elt -- ? ) -- xf' )
    negate xfilter ; inline

: xsample ( xf prob -- xf' )
    '[ drop random-unit _ < ] xfilter ;

: xtake ( xf n -- xf )
    [let :> n!
        '[
            n [ drop <reduced> ] [
                _ dip over { [ reduced? ] [ null eq? ] } 1||
                [ drop ] [ 1 - n! ] if
            ] if-zero ] xf
    ] ; inline

: xdrop ( xf n -- xf' )
    [let :> n! '[ n [ 1 - n! drop null ] unless-zero ] xmap ] ; inline

: xtake-until ( xf quot: ( elt -- ? ) -- xf' )
    '[
        _ keepd over dup { [ reduced? ] [ null eq? ] } 1||
        [ 2drop ] [ @ [ nip <reduced> ] [ drop ] if ] if
    ] ; inline

: xtake-while ( xf quot: ( elt -- ? ) -- xf' )
    negate xtake-until ; inline

: xdrop-while ( xf quot: ( elt -- ? ) -- xf' )
    '[ dup @ [ drop null ] unless ] xmap ; inline

: xdrop-until ( xf quot: ( elt -- ? ) -- xf' )
    negate xdrop-while ;

: xaccumulate ( xf identity quot: ( prev elt -- next ) -- xf' )
    [ 1vector ] dip '[ _ [ last @ ] [ push ] [ ] tri ] xmap ; inline

:: xgroup ( xf n -- xf' )
    V{ } clone :> accum
    xf [
        accum [
            dup ?last [
                dup length n < [ nip push ] [
                    drop [ 1vector ] [ push ] bi*
                ] if
            ] [
                [ 1vector ] [ push ] bi*
            ] if*
        ] keep
    ] xmap ; inline

:: xsplit-when ( xf quot: ( elt -- ? ) -- xf' )
    V{ } clone :> accum
    xf [
        accum [
            over quot call [ V{ } clone suffix! ] when
            index-of-last [ ?push ] change-nth
        ] keep
    ] xmap ; inline

: xenumerate ( xf -- xf' )
    [let 0 :> n! [ n dup 1 + n! swap 2array ] xmap ] ; inline


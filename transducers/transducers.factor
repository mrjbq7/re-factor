! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators.short-circuit kernel
make math prettyprint random sequences sets vectors ;

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

MACRO: transduce ( quot: ( xf -- xf' ) -- result )
    [ [ nip ] swap call ] [ ] make swap '[ @ null _ (transduce) ] ;

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
    [let f :> n! '[ _ n! ] % [ [ n 1 + n! ] when n ] xmap ] ; inline

: xcount ( xf -- xf' )
    0 xcount-from ;

: xsum ( xf -- xf' )
    [let f :> n! [ 0 n! ] % [ n + n! n ] xmap ] ; inline

: xproduct ( xf -- xf' )
    [let f :> n! [ 1 n! ] % [ n * n! n ] xmap ] ; inline

: xhistogram ( xf -- xf' )
    [let f :> h! [ H{ } clone h! ] %
        [ h [ inc-at ] keep ] xmap
    ] ; inline

: xcollect ( xf -- xf' )
    [let f :> v! [ V{ } clone v! ] %
        [ v [ push ] keep ] xmap
    ] ; inline

: xgroup-by ( xf quot: ( elt -- key ) -- xf' )
    [let f :> h! [ H{ } clone h! ] %
        '[ _ keep swap h [ push-at ] keep ] xmap
    ] ; inline

: xdedupe-when ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    [let null :> prior! [ null prior! ] %
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
    [let f :> n! '[ _ n! ] %
        '[
            n [ drop <reduced> ] [
                _ dip over { [ reduced? ] [ null eq? ] } 1||
                [ drop ] [ 1 - n! ] if
            ] if-zero ] xf
    ] ; inline

: xdrop ( xf n -- xf' )
    [let f :> n! '[ _ n! ] %
        '[ n [ 1 - n! drop null ] unless-zero ] xmap
    ] ; inline

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
    f :> accum! [ V{ } clone accum! ] %
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
    f :> accum! [ V{ } clone accum! ] %
    xf [
        accum [
            over quot call [ V{ } clone suffix! ] when
            index-of-last [ ?push ] change-nth
        ] keep
    ] xmap ; inline

: xpartition ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    [let null :> prior! [ null prior! ] %
        '[ prior swap dup prior! @ ] xsplit-when
    ] ; inline

: xmonotonic-split ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    '[ over null eq? [ 2drop t ] [ @ not ] if ] xpartition ; inline

: xenumerate ( xf -- xf' )
    [let f :> n! [ 0 n! ] % [ n dup 1 + n! swap 2array ] xmap ] ; inline

: xunique ( xf -- xf' )
    [let f :> s! [ HS{ } clone s! ] %
        '[ [ s ?adjoin ] keep null ? ] xmap
    ] ; inline

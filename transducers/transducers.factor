! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators.short-circuit kernel
make math namespaces prettyprint random sequences sets vectors ;

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

! each transducer can optionally add ``init`` and ``done``
! logic when being compiled, typically the function returns
! the ``step`` quotation

: xinit ( quot -- ) \ xinit [ prepose ] change ;
: xdone ( quot -- ) \ xdone [ prepose ] change ;

MACRO: transduce ( quot: ( xf -- xf' ) -- result )
    H{ { xinit [ ] } { xdone [ ] } } [
        [ nip ] swap call \ xinit get swap \ xdone get
    ] with-variables '[ @ null _ (transduce) @ ] ;

: xf ( rf: ( prev elt -- next ) -- xf )
    '[ { [ over reduced? ] [ dup null eq? ] } 0|| [ drop ] _ if ] ;

: xmap ( xf quot: ( elt -- newelt ) -- xf' )
    '[ @ dup { [ reduced? ] [ null eq? ] } 1|| _ unless ] xf ;

: xfind ( xf quot: ( elt -- ? ) -- xf' )
    '[ dup @ [ <reduced> ] when ] xmap ;

: xpprint ( xf -- xf' )
    [ dup . ] xmap ;

: xbreak ( xf -- xf' )
    [ B ] xmap ;

: xcount-from ( xf n -- xf' )
    [let f :> n! '[ _ n! ] xinit [ [ n 1 + n! ] when n ] xmap ] ;

: xcount ( xf -- xf' )
    0 xcount-from ;

: xsum ( xf -- xf' )
    [let f :> n! [ 0 n! ] xinit [ n + n! n ] xmap ] ;

: xproduct ( xf -- xf' )
    [let f :> n! [ 1 n! ] xinit [ n * n! n ] xmap ] ;

: xhistogram ( xf -- xf' )
    [let f :> h!
        [ H{ } clone h! ] xinit
        [ h [ inc-at ] keep ] xmap
        [ f h! ] xdone
    ] ;

: xcollect ( xf -- xf' )
    [let f :> v!
        [ V{ } clone v! ] xinit
        [ v [ push ] keep ] xmap
        [ f v! ] xdone
    ] ;

: xgroup-by ( xf quot: ( elt -- key ) -- xf' )
    [let f :> h!
        [ H{ } clone h! ] xinit
        '[ _ keep swap h [ push-at ] keep ] xmap
        [ f h! ] xdone
    ] ;

: xdedupe-when ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    [let null :> prior!
        [ null prior! ] xinit
        '[ prior over @ [ drop null ] [ dup prior! ] if ] xmap
        [ null prior! ] xdone
    ] ;

: xdedupe-eq ( xf -- xf' ) [ eq? ] xdedupe-when ;

: xdedupe ( xf -- xf' ) [ = ] xdedupe-when ;

: xfilter ( xf quot: ( elt -- ? ) -- xf' )
    '[ dup @ [ drop null ] unless ] xmap ;

: xreject ( xf quot: ( elt -- ? ) -- xf' )
    negate xfilter ;

: xsample ( xf prob -- xf' )
    '[ drop random-unit _ < ] xfilter ;

: xtake ( xf n -- xf )
    [let f :> n!
        '[ _ n! ] xinit
        '[
            n [ drop <reduced> ] [
                _ dip over { [ reduced? ] [ null eq? ] } 1||
                [ drop ] [ 1 - n! ] if
            ] if-zero ] xf
    ] ;

: xdrop ( xf n -- xf' )
    [let f :> n!
        '[ _ n! ] xinit
        '[ n [ 1 - n! drop null ] unless-zero ] xmap
    ] ;

: xtake-until ( xf quot: ( elt -- ? ) -- xf' )
    '[
        _ keepd over dup { [ reduced? ] [ null eq? ] } 1||
        [ 2drop ] [ @ [ nip <reduced> ] [ drop ] if ] if
    ] ;

: xtake-while ( xf quot: ( elt -- ? ) -- xf' )
    negate xtake-until ;

: xdrop-while ( xf quot: ( elt -- ? ) -- xf' )
    '[ dup @ [ drop null ] unless ] xmap ;

: xdrop-until ( xf quot: ( elt -- ? ) -- xf' )
    negate xdrop-while ;

: xaccumulate ( xf identity quot: ( prev elt -- next ) -- xf' )
    [ 1vector ] dip '[ _ [ last @ ] [ push ] [ ] tri ] xmap ;

:: xgroup ( xf n -- xf' )
    f :> accum!
    [ V{ } clone accum! ] xinit
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
    ] xmap
    [ f accum! ] xdone ;

:: xsplit-when ( xf quot: ( elt -- ? ) -- xf' )
    f :> accum!
    [ V{ } clone accum! ] xinit
    xf [
        accum [
            over quot call [ V{ } clone suffix! ] when
            index-of-last [ ?push ] change-nth
        ] keep
    ] xmap
    [ f accum! ] xdone ;

: xpartition ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    [let null :> prior!
        [ null prior! ] xinit
        '[ prior swap dup prior! @ ] xsplit-when
        [ null prior! ] xdone
    ] ;

: xmonotonic-split ( xf quot: ( elt1 elt2 -- ? ) -- xf' )
    '[ over null eq? [ 2drop t ] [ @ not ] if ] xpartition ;

: xenumerate ( xf -- xf' )
    [let f :> n! [ 0 n! ] xinit [ n dup 1 + n! swap 2array ] xmap ] ;

: xunique ( xf -- xf' )
    [let f :> s!
        [ HS{ } clone s! ] xinit
        '[ [ s ?adjoin ] keep null ? ] xmap
        [ f s! ] xdone
    ] ;

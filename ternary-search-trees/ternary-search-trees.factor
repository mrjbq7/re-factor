USING: accessors arrays assocs combinators kernel locals make
math math.order sbufs sequences strings ;

IN: ternary-search-trees

<PRIVATE

TUPLE: tree-node ch value exists lt eq gt ;

: <tree-node> ( -- node )
    tree-node new ;

: ensure-lt ( node -- child )
    dup lt>> [ nip ] [ <tree-node> >>lt lt>> ] if* ;

: ensure-eq ( node -- child )
    dup eq>> [ nip ] [ <tree-node> >>eq eq>> ] if* ;

: ensure-gt ( node -- child )
    dup gt>> [ nip ] [ <tree-node> >>gt gt>> ] if* ;

:: (search) ( node ch -- node/f )
    node [
        ch node ch>> <=> {
            { +lt+ [ node lt>> ch (search) ] }
            { +gt+ [ node gt>> ch (search) ] }
            [ drop node ]
        } case
    ] [ f ] if ; inline recursive

: search ( node key -- node/f )
    [ over [ [ eq>> ] dip (search) ] [ drop ] if dup not ]
    find 2drop ;

: (insert) ( node ch -- node' )
    over ch>> [
        dupd <=> swapd {
            { +lt+ [ ensure-lt swap (insert) ] }
            { +gt+ [ ensure-gt swap (insert) ] }
            [ drop nip ]
        } case
    ] [ >>ch ] if* ; inline recursive

: insert ( value key node -- ? )
    swap [ [ ensure-eq ] dip (insert) ] each swap >>value
    [ exists>> ] [ t >>exists drop ] bi ;

PRIVATE>

! The root is a sentinel: its value represents the empty key, and
! its eq link points to the first character level.
TUPLE: ternary-search-tree root count ;

: <ternary-search-tree> ( -- tree )
    f 0 ternary-search-tree boa ;

: >ternary-search-tree ( assoc -- tree )
    <ternary-search-tree> assoc-clone-like ;

M: ternary-search-tree at*
    root>> swap search
    [ [ value>> ] [ exists>> ] bi ] [ f f ] if* ;

M: ternary-search-tree new-assoc
    2drop <ternary-search-tree> ;

M: ternary-search-tree clear-assoc
    f >>root 0 >>count drop ;

M: ternary-search-tree delete-at
    [ root>> swap search dup [ exists>> ] [ f ] if* ] keep
    swap [
        [ 1 - ] change-count drop
        f >>value f >>exists drop
    ] [ 2drop ] if ;

M: ternary-search-tree assoc-size count>> ;

<PRIVATE

: ensure-root ( tree -- node )
    dup root>> [ nip ] [ <tree-node> >>root root>> ] if* ;

PRIVATE>

M: ternary-search-tree set-at
    [ ensure-root insert ] keep
    swap [ [ 1 + ] change-count ] unless drop ;

<PRIVATE

:: emit-entry ( key node -- )
    node exists>> [ key >string node value>> 2array , ] when ;

:: (>alist) ( key node/f -- )
    node/f [ :> node
        key node lt>> (>alist)
        node ch>> key push
        key node emit-entry
        key node eq>> (>alist)
        key pop drop
        key node gt>> (>alist)
    ] when* ;

PRIVATE>

:: prefix>alist ( prefix tree -- alist )
    tree root>> prefix search [ :> node
        prefix >sbuf :> key
        [
            key node emit-entry
            key node eq>> (>alist)
        ] { } make
    ] [ { } ] if* ;

M: ternary-search-tree >alist
    "" swap prefix>alist ;

M: tree-node clone
    call-next-method
    [ dup [ clone ] when ] change-lt
    [ dup [ clone ] when ] change-eq
    [ dup [ clone ] when ] change-gt ;

M: ternary-search-tree clone
    call-next-method [ dup [ clone ] when ] change-root ;

M: ternary-search-tree assoc-like
    drop dup ternary-search-tree?
    [ >ternary-search-tree ] unless ;

INSTANCE: ternary-search-tree assoc

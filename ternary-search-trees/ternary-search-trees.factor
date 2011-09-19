
USING: accessors accessors.maybe arrays assocs combinators fry
kernel make math math.order sequences strings ;

IN: ternary-search-trees

<PRIVATE

<<
TUPLE: tree-node ch value exists lt eq gt ;
tree-node define-maybe-accessors
>>

: <tree-node> ( -- node )
    tree-node new ;

: (search) ( node ch -- node/f )
    over ch>> [
        dupd <=> swapd {
            { +lt+ [ lt>> dup [ swap (search) ] [ nip ] if ] }
            { +gt+ [ gt>> dup [ swap (search) ] [ nip ] if ] }
            [ drop nip ]
        } case [ eq>> ] [ f ] if*
    ] [ 2drop f ] if* ; inline recursive

: search ( node key -- node/f )
    [ over [ (search) ] [ drop ] if dup not ] find 2drop ;

! FIXME: don't have leaf nodes, store value in eq?

: (insert) ( node ch -- node' )
    over ch>> [
        dupd <=> swapd {
            { +lt+ [ [ <tree-node> ] maybe-lt swap (insert) ] }
            { +gt+ [ [ <tree-node> ] maybe-gt swap (insert) ] }
            [ drop nip ]
        } case
    ] [ >>ch ] if* [ <tree-node> ] maybe-eq ; inline recursive

: insert ( value key node -- ? )
    swap [ (insert) ] each swap >>value
    [ exists>> ] [ t >>exists drop ] bi ;

PRIVATE>

<<
TUPLE: ternary-search-tree root count ;
ternary-search-tree define-maybe-accessors
>>

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

M: ternary-search-tree set-at
    [ [ <tree-node> ] maybe-root insert ] keep
    swap [ [ 1 + ] change-count ] unless drop ;

: (>alist) ( key node/f -- )
    [
        dup exists>> [ over over value>> 2array , ] when
        [ dupd lt>> (>alist) ]
        [
            dupd
            [ ch>> [ 1string append ] when* ] [ eq>> ] bi
            (>alist)
        ]
        [ dupd gt>> (>alist) ] tri drop
    ] [ drop ] if* ;

M: ternary-search-tree >alist
    "" swap root>> [ (>alist) ] { } make ;

M: ternary-search-tree clone
    >alist >ternary-search-tree ;

M: ternary-search-tree assoc-like
    drop dup ternary-search-tree?
    [ >ternary-search-tree ] unless ;

INSTANCE: ternary-search-tree assoc

! FIXME: : partial-search ( str -- ) drop ;
! FIXME: : near-search ( str -- ) drop ;


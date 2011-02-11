
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

USE: io
USE: prettyprint


! : (search) ( ch node/f -- node/f )
!     [
!         {
!             { [ 2dup < ] [ drop [ lt>> ] dip (search) ] }
!             { [ 2dup > ] [ drop [ gt>> ] dip (search) ] }
!             [ 2drop ]
!         } cond
!     ] [ drop ] if*
! 
!     ;

: (search) ( node ch -- node/f )
    over ch>> [
        dupd >=< swapd {
            { +eq+ [ nip ] }
            { +lt+ [ lt>> dup [ swap (search) ] [ nip ] if ] }
            { +gt+ [ gt>> dup [ swap (search) ] [ nip ] if ] }
        } case [ eq>> ] [ f ] if*
    ] [ 2drop f ] if* ;

: search ( key node -- node/f )
    [ 2dup [ empty? not ] [ and ] bi* ] [
        [ unclip-slice ] dip swap (search)
    ] while nip ;


! Try cond instead of <=> case
! Fewer nodes ?
! String's hashcode is stored (e.g., "3 slot")
! FIXME: don't have leaf nodes, store value in eq?

: (insert) ( node ch -- node' )
    over ch>> [
        dupd >=< swapd {
            { +eq+ [ nip ] }
            { +lt+ [ [ <tree-node> ] maybe-lt swap (insert) ] }
            { +gt+ [ [ <tree-node> ] maybe-gt swap (insert) ] }
        } case
    ] [ >>ch ] if* [ <tree-node> ] maybe-eq ;

: insert ( value key node -- )
    swap [ (insert) ] each swap >>value t >>exists drop ;

PRIVATE>

<<
TUPLE: ternary-search-tree root count ;
ternary-search-tree define-maybe-accessors
>>

: <ternary-search-tree> ( -- tree )
    f 0 ternary-search-tree boa ;

: >ternary-search-tree ( assoc -- tree )
    <ternary-search-tree> assoc-clone-like ;

M: ternary-search-tree at* ( key tree -- value ? )
    root>> search [ [ value>> ] [ exists>> ] bi ] [ f f ] if* ;

M: ternary-search-tree new-assoc ( capacity exemplar -- newassoc )
    2drop <ternary-search-tree> ;

M: ternary-search-tree clear-assoc ( tree -- )
    f >>root 0 >>count drop ;

M: ternary-search-tree delete-at ( key tree -- )
    [ root>> search dup [ exists>> ] [ f ] if* ] keep
    swap [
        [ 1 - ] change-count drop
        f >>value f >>exists drop
    ] [ 2drop ] if ;

M: ternary-search-tree assoc-size ( tree -- n )
    count>> ;

M: ternary-search-tree set-at ( value key tree -- )
    [ 1 + ] change-count [ <tree-node> ] maybe-root insert ;

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


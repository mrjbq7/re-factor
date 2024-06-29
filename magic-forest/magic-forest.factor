USING: arrays combinators.short-circuit command-line hash-sets
kernel math math.parser namespaces prettyprint sequences sets ;

IN: magic-forest

! brute force

: wolf-devours-goat ( forest -- forest/f )
    first3 { [ pick 0 > ] [ over 0 > ] } 0&&
    [ [ 1 - ] [ 1 - ] [ 1 + ] tri* 3array ] [ 3drop f ] if ;

: lion-devours-goat ( forest -- forest/f )
    first3 { [ pick 0 > ] [ dup 0 > ] } 0&&
    [ [ 1 - ] [ 1 + ] [ 1 - ] tri* 3array ] [ 3drop f ] if ;

: lion-devours-wolf ( forest -- forest/f )
    first3 { [ dup 0 > ] [ over 0 > ] } 0&&
    [ [ 1 + ] [ 1 - ] [ 1 - ] tri* 3array ] [ 3drop f ] if ;

: next-forests ( set forest -- set' )
    [ wolf-devours-goat [ over adjoin ] when* ]
    [ lion-devours-goat [ over adjoin ] when* ]
    [ lion-devours-wolf [ over adjoin ] when* ] tri ;

: meal ( forests -- forests' )
    [ length 3 * <hash-set> ] keep [ next-forests ] each members ;

: stable? ( forest -- ? )
    first3 rot zero? [ [ zero? ] either? ] [ [ zero? ] both? ] if ;

: devouring-possible? ( forests -- ? )
    [ stable? ] none? ;

: stable-forests ( forests -- stable-forests )
    [ stable? ] filter ;

: find-stable-forests ( forest -- forests )
    1array [ dup devouring-possible? ] [ meal ] while stable-forests ;

MAIN: [
    command-line get [ string>number ] map
    find-stable-forests .
]

USING: arrays combinators.short-circuit hash-sets kernel math
math.vectors sequences sequences.private sets ;

IN: magic-forest

: >forest< ( forest -- goats wolves lions )
    { array } declare first3-unsafe
    { array-capacity array-capacity array-capacity } declare ; inline

: wolf-devours-goat ( forest -- forest/f )
    >forest< { [ pick 0 > ] [ over 0 > ] } 0&&
    [ [ 1 - ] [ 1 - ] [ 1 + ] tri* 3array ] [ 3drop f ] if ;

: lion-devours-goat ( forest -- forest/f )
    >forest< { [ pick 0 > ] [ dup 0 > ] } 0&&
    [ [ 1 - ] [ 1 + ] [ 1 - ] tri* 3array ] [ 3drop f ] if ;

: lion-devours-wolf ( forest -- forest/f )
    >forest< { [ dup 0 > ] [ over 0 > ] } 0&&
    [ [ 1 + ] [ 1 - ] [ 1 - ] tri* 3array ] [ 3drop f ] if ;

: next-forests ( set forest -- set' )
    [ wolf-devours-goat [ over adjoin ] when* ]
    [ lion-devours-goat [ over adjoin ] when* ]
    [ lion-devours-wolf [ over adjoin ] when* ] tri ; inline

: meal ( forests -- forests' )
    [ length <hash-set> ] keep [ next-forests ] each members ;

: stable? ( forest -- ? )
    >forest< rot zero?
    [ [ zero? ] either? ] [ [ zero? ] both? ] if ;

: devouring-possible? ( forests -- ? )
    [ stable? ] any? not ;

: stable-forests ( forests -- stable-forests )
    [ stable? ] filter ;

: find-stable-forests ( forest -- forests )
    2 over bounds-check? [ throw ] unless 1array
    [ dup devouring-possible? ] [ meal ] while stable-forests ;

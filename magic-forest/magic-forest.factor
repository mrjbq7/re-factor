USING: arrays combinators.short-circuit hash-sets kernel math
math.vectors sequences sequences.private sets ;

IN: magic-forest

ALIAS: goats first-unsafe
ALIAS: wolves second-unsafe
ALIAS: lions third-unsafe

: wolf-devours-goat ( forest -- forest/f )
    dup { [ goats 0 > ] [ wolves 0 > ] } 1&&
    [ { -1 -1 1 } v+ ] [ drop f ] if ;

: lion-devours-goat ( forest -- forest/f )
    dup { [ goats 0 > ] [ lions 0 > ] } 1&&
    [ { -1 1 -1 } v+ ] [ drop f ] if ;

: lion-devours-wolf ( forest -- forest/f )
    dup { [ lions 0 > ] [ wolves 0 > ] } 1&&
    [ { 1 -1 -1 } v+ ] [ drop f ] if ;

: next-forests ( set forest -- set' )
    [ wolf-devours-goat [ over adjoin ] when* ]
    [ lion-devours-goat [ over adjoin ] when* ]
    [ lion-devours-wolf [ over adjoin ] when* ] tri ; inline

: meal ( forests -- forests' )
    [ length <hash-set> ] keep [ next-forests ] each members ;

: stable? ( forest -- ? )
    [ wolves ] [ lions ] [ goats zero? ] tri
    [ [ zero? ] either? ] [ [ zero? ] both? ] if ;

: devouring-possible? ( forests -- ? )
    [ stable? not ] any? ;

: stable-forests ( forests -- stable-forests )
    [ stable? ] filter ;

: find-stable-forests ( forest -- forests )
    2 over bounds-check? [ throw ] unless 1array
    [ dup devouring-possible? ] [ meal ] while stable-forests ;

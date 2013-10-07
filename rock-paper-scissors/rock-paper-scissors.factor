USING: combinators formatting io kernel multi-methods random ;
FROM: multi-methods => GENERIC: ;
IN: rock-paper-scissors

SINGLETONS: rock paper scissors ;

GENERIC: win? ( obj1 obj2 -- ? )

METHOD: win? { paper scissors } 2drop t ;
METHOD: win? { scissors rock } 2drop t ;
METHOD: win? { rock paper } 2drop t ;
METHOD: win? { object object } 2drop f ;

: play. ( obj1 obj2 -- )
    {
        { [ 2dup win? ] [ "WIN" ] }
        { [ 2dup = ] [ "TIE" ] }
        [ "LOSE" ]
    } cond "%s vs. %s: %s\n" printf ;

: computer ( -- obj )
    { rock paper scissors } random ;

: rock ( -- ) \ rock computer play. ;

: paper ( -- ) \ paper computer play. ;

: scissors ( -- ) \ scissors computer play. ;

USING: combinators formatting io kernel multi-methods random ;
FROM: multi-methods => GENERIC: ;
IN: rock-paper-scissors

SINGLETONS: rock paper scissors ;

GENERIC: beats? ( obj1 obj2 -- ? )

METHOD: beats? { scissors paper } 2drop t ;
METHOD: beats? { rock scissors } 2drop t ;
METHOD: beats? { paper rock } 2drop t ;
METHOD: beats? { object object } 2drop f ;

: play. ( obj1 obj2 -- )
    {
        { [ 2dup beats? ] [ "WIN" ] }
        { [ 2dup = ] [ "TIE" ] }
        [ "LOSE" ]
    } cond "%s vs. %s: %s\n" printf ;

: computer ( -- obj )
    { rock paper scissors } random ;

: rock ( -- ) \ rock computer play. ;

: paper ( -- ) \ paper computer play. ;

: scissors ( -- ) \ scissors computer play. ;


USING: combinators kernel math sequences ;

IN: happy-numbers

<PRIVATE

: squares ( n -- s )
    0 [ over 0 > ] [ [ 10 /mod sq ] dip + ] while nip ;

: (happy?) ( n1 n2 -- ? )
    [ squares ] [ squares squares ] bi* {
        { [ dup 1 = ] [ 2drop t ] }
        { [ 2dup = ] [ 2drop f ] }
        [ (happy?) ]
    } cond ;

PRIVATE>

: happy? ( n -- ? )
    dup (happy?) ;



USING: accessors arrays calendar combinators formatting grouping
io kernel math random sequences threads ;

IN: slot-machine

CONSTANT: SYMBOLS "☀☁☂☃"

: spin ( value -- value' )
    SYMBOLS remove random ;

: spin-delay ( n -- )
    15 * 25 + milliseconds sleep ;

: spin-slots ( a b c n -- a b c )
    {
        [ spin-delay ]
        [ 10 < [ [ spin ] 2dip ] when ]
        [ 15 < [ [ spin ]  dip ] when ]
        [ drop spin ]
    } cleave ;

: print-spin ( a b c -- a b c )
    "\e[0;0H" write
    "Welcome to the Factor slot machine!" print nl
    "  +--------+" print
    "  | CASINO |" print
    "  |--------| *" print
    3dup "  |%c |%c |%c | |\n" printf
    "  |--------|/" print
    "  |    [_] |" print
    "  +--------+" print flush ;

: winner? ( a b c -- )
    3array all-equal? nl "You WIN!" "You LOSE!" ? print nl ;

: play-slots ( -- )
    "\e[0;0H\e[2J" write
    f f f 20 <iota> [ spin-slots print-spin ] each winner? ;

: continue? ( -- ? )
    "Press ENTER to play again." write flush readln ;

: main-slots ( -- )
    [ play-slots continue? ] loop ;

MAIN: main-slots

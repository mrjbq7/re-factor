! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: ascii combinators fry kernel math sequences ;

IN: successor

: carry ( elt last first -- ? elt' )
    '[ _ > dup _ ] keep ? ;

: next-digit ( ch -- ? ch' )
    1 + CHAR: 9 CHAR: 0 carry ;

: next-letter ( ch -- ? ch' )
    [ ch>lower 1 + CHAR: z CHAR: a carry ] [ LETTER? ] bi
    [ ch>upper ] when ;

: next-char ( ch -- ? ch' )
    {
        { [ dup digit?  ] [ next-digit  ] }
        { [ dup Letter? ] [ next-letter ] }
        [ t swap ]
    } cond ;

: (successor) ( str -- str' )
    dup length t [ over 0 > dupd and ] [
        drop 1 - dup pick [ next-char ] change-nth
    ] while nip [ dup first prefix ] when ;

: successor ( str -- str' )
    dup empty? [ (successor) ] unless ;

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

: map-until ( seq quot: ( elt -- ? elt' ) -- seq' ? )
    [ t 0 pick length '[ 2dup _ < and ] ] dip '[
        nip [ over _ change-nth ] keep 1 +
    ] while drop ; inline

: successor ( str -- str' )
    dup empty? [
        reverse [ next-char ] map-until
        [ dup last suffix ] when reverse
    ] unless ;
! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math sequences ;

IN: icalendar

<PRIVATE

: next-content-line ( string n -- i )
    "\r\n" 2over subseq-start-from dup [
        pick [ dup 2 + ] [ ?nth ] bi* CHAR: \s =
        [ nip 2 + next-content-line ] [ 2nip ] if
    ] [ 2nip ] if ; recursive

PRIVATE>

: content-lines ( string -- lines )
    0
    [ 2dup next-content-line dup ]
    [ [ pick subseq ] [ 2 + ] bi swap ]
    produce nip [ tail ] dip swap
    [ suffix ] unless-empty ;

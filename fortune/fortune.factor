! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io io.encodings.ascii io.files kernel make memoize
random sequences splitting strings ;

IN: fortune

CONSTANT: FORTUNES {
    "/usr/games/fortune/fortunes"
    "/usr/share/fortune/fortunes"
    "/usr/share/games/fortune/fortunes"
    "/usr/share/games/fortunes/fortunes"
    "/usr/local/share/games/fortune/fortunes"
    "/opt/local/share/games/fortune/fortunes"
}

: parse-fortune ( str -- seq )
    [
        [ "%\n" split1-slice dup ]
        [ swap , ] while drop ,
    ] { } make ;

: load-fortunes ( path -- seq )
    ascii file-contents parse-fortune ;

MEMO: default-fortunes ( -- seq )
    FORTUNES [ file-exists? ] find nip load-fortunes ;

: fortune ( -- )
    default-fortunes random >string print ;

MAIN: fortune


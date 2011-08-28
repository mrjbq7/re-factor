! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii kernel locals math random sequences utils
;

IN: enigma

: <alphabet> ( -- seq )
    26 iota { } like ;

: rotate ( seq n -- seq' )
    cut swap append ;

: <cog> ( -- cog )
    <alphabet> randomize ;

: remove-random ( seq -- seq' elt )
    [ length random ] keep [ nth ] [ remove-nth ] 2bi swap ;

: <reflector> ( -- reflector )
    <alphabet> dup length iota [ dup empty? ] [
        over [
            remove-random [ remove-random ] dip
        ] dip exchange
    ] until drop ;

TUPLE: enigma cogs prev-cogs reflector print-special? ;

: <enigma> ( num-cogs -- enigma )
    [ <cog> ] replicate dup { } clone-like <reflector> t enigma boa ;

: reset-cogs ( enigma -- enigma )
    dup prev-cogs>> >>cogs ;

: special? ( n -- ? )
    [ 25 > ] [ 0 < ] bi or ;

:: encode ( text enigma -- cipher-text )
    0 :> ln!
    enigma cogs>> :> cogs
    enigma reflector>> :> reflector
    text >lower [
        CHAR: a mod dup special? [
            enigma print-special?>> [ drop f ] unless
        ] [
            ln 1 + ln!
            cogs [ nth ] each reflector nth
            cogs reverse [ index ] each CHAR: a +
            cogs length iota [ 6 * 1 + ln mod zero? ] filter
            cogs [ 1 rotate ] change-nths
        ] if
    ] map ;

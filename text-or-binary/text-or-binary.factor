! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io io.encodings.binary io.files kernel math sequences ;

IN: text-or-binary

<PRIVATE

: includes-zeros? ( seq -- ? )
    0 swap member? ;

: majority-printable? ( seq -- ? )
    [ t ] [
        [ [ 31 > ] filter ] keep [ length ] bi@ / 0.85 >
    ] if-empty ;

PRIVATE>

: text? ( seq -- ? )
    [ includes-zeros? not ] [ majority-printable? ] bi and ;

: text-file? ( path -- ? )
    binary [ 1024 read text? ] with-file-reader ;

: binary? ( seq -- ? )
    text? not ;

: binary-file? ( path -- ? )
    text-file? not ;


! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line io io.encodings.utf8 io.files kernel
namespaces sets sequences ;

IN: unix-tools.uniq

: uniq-lines ( -- )
    HS{ } clone [
        dup pick in? [ drop ] [
            [ over adjoin ]
            [ print flush ] bi
        ] if
    ] each-line drop ;

: uniq-file ( path -- )
    utf8 [ uniq-lines ] with-file-reader ;

: run-uniq ( -- )
    command-line get [
        first dup "-" = [ drop uniq-lines ] [ uniq-file ] if
    ] unless-empty ;

MAIN: run-uniq

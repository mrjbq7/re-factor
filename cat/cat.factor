! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line continuations kernel io io.encodings.binary
io.files namespaces sequences strings ;

IN: cat

: cat-stream ( -- )
    [ 1024 read dup ] [ >string write flush ] while drop ;

: cat-file ( path -- )
    binary [ cat-stream ] with-file-reader ;

: cat-files ( paths -- )
    [
        [ cat-file ] [
            drop write ": not found" write nl flush
        ] recover
    ] each ;

: cat-lines ( -- )
    [ write nl flush ] each-line ;

: run-cat ( -- )
    command-line get [ cat-lines ] [ cat-files ] if-empty ;

MAIN: run-cat


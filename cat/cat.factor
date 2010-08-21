! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line kernel io io.encodings.binary io.files
namespaces sequences strings ;

IN: cat

: cat-lines ( -- )
    [ write nl flush ] each-line ;

: cat-stream ( -- )
    [ 1024 read dup ] [ >string write flush ] while drop ;

: cat-file ( path -- )
    dup exists?
    [ binary [ cat-stream ] with-file-reader ]
    [ write ": not found" write nl flush ] if ;

: cat-files ( paths -- )
    [ dup "-" = [ drop cat-lines ] [ cat-file ] if ] each ;

: run-cat ( -- )
    command-line get [ cat-lines ] [ cat-files ] if-empty ;

MAIN: run-cat


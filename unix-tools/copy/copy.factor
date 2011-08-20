! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators command-line io io.directories io.files.info
kernel math namespaces sequences ;

IN: unix-tools.copy

: usage ( -- )
    "Usage: copy source ... target" print ;

: copy-to-dir ( args -- )
    dup last file-info directory?
    [ unclip-last copy-files-into ] [ drop usage ] if ;

: copy-to-file ( args -- )
    dup last file-info directory?
    [ copy-to-dir ] [ first2 copy-file ] if ;

: run-copy ( -- )
    command-line get dup length {
        { [ dup 2 > ] [ drop copy-to-dir  ] }
        { [ dup 2 = ] [ drop copy-to-file ] }
        [ 2drop usage ]
    } cond ;

MAIN: run-copy

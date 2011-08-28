! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators command-line continuations
formatting io io.directories io.files.types io.pathnames kernel
math math.order namespaces sequences sorting utils ;

IN: unix-tools.tree

SYMBOL: #files
SYMBOL: #directories

: usage ( -- )
    "Usage: tree directory ..." print ;

: indent ( n -- )
    [ [ "|   " write ] times ] unless-zero "+-- " write ;

: write-name ( indent entry -- )
    [ indent ] [ name>> write ] bi* ;

: write-file ( indent entry -- )
    write-name #files [ 1 + ] change-global ;

DEFER: write-tree

: write-dir ( indent entry -- )
    [ write-name ] [
        [ [ 1 + ] [ name>> ] bi* write-tree ]
        [ 3drop " [error opening dir]" write ] recover
    ] 2bi #directories [ 1 + ] change-global ;

: write-tree ( indent path -- )
    [
        [ name>> ] sort-with [
            nl [ dup ] bi@ type>> +directory+ =
            [ write-dir ] [ write-file ] if
        ] each drop
    ] with-directory-entries ;

: tree ( path -- )
    0 #directories set-global 0 #files set-global
    [ write ] [ 0 swap write-tree ] bi nl
    #directories get-global #files get-global
    "\n%d directories, %d files\n" printf ;

: run-tree ( -- )
    command-line get [  usage ] [ [ tree ] each ] if-empty ;

MAIN: run-tree

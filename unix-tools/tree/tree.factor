! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors command-line continuations formatting io
io.directories io.files.types io.pathnames kernel locals math
namespaces sequences sorting ;
FROM: namespaces => change-global ;
IN: unix-tools.tree

SYMBOL: #files
SYMBOL: #directories

: indent ( #indents last? -- )
    [ [ [ "|   " write ] times ] unless-zero ]
    [ "└── " "├── " ? write ] bi* ;

: write-name ( entry #indents last? -- )
    indent name>> write ;

: write-file ( entry #indents last? -- )
    write-name #files [ 1 + ] change-global ;

DEFER: write-tree

: write-dir ( entry #indents last? -- )
    [ write-name ] [
        drop
        [ [ name>> ] [ 1 + ] bi* write-tree ]
        [ 3drop " [error opening dir]" write ] recover
    ] 3bi #directories [ 1 + ] change-global ;

: write-entry ( entry #indents last? -- )
    nl pick type>> +directory+ =
    [ write-dir ] [ write-file ] if ;

:: write-tree ( path #indents -- )
    path [
        [ name>> ] sort-with [ ] [
            unclip-last
            [ [ #indents f write-entry ] each ]
            [ #indents t write-entry ] bi*
        ] if-empty
    ] with-directory-entries ;

: tree ( path -- )
    0 #directories set-global 0 #files set-global
    [ write ] [ 0 write-tree ] bi nl
    #directories get-global #files get-global
    "\n%d directories, %d files\n" printf ;

: run-tree ( -- )
    command-line get [
        current-directory get tree
    ] [
        [ tree ] each
    ] if-empty ;

MAIN: run-tree

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs formatting io io.pathnames kernel locals
sequences vocabs vocabs.loader vocabs.metadata ;

IN: todos

: vocab-todo-path ( vocab -- string )
    vocab-dir "todo.txt" append-path ;

: vocab-todo ( vocab -- todos )
    dup vocab-todo-path vocab-file-contents ;

: set-vocab-todo ( todos vocab -- )
    dup vocab-todo-path set-vocab-file-contents ;

:: add-vocab-todo ( todo vocab -- )
    CHAR: \n todo member? [ "invalid" throw ] when
    vocab vocab-todo :> todos
    todo todos member? [
        todos todo suffix vocab set-vocab-todo
    ] unless ;

: todos. ( vocab -- )
    vocab-todo [ print ] each ;

: all-todos ( vocab -- assoc )
    child-vocabs [ dup vocab-todo 2array ] map
    [ second empty? not ] filter ;

: all-todos. ( vocab -- )
    all-todos [
        [ "%s:\n" printf ] [ [ "- %s\n" printf ] each ] bi*
    ] assoc-each ;

USING: lexer namespaces strings strings.parser.private
unicode vocabs.parser ;

SYNTAX: TODO:
    lexer get [ rest-of-line ] [ next-line ] bi
    [ blank? ] trim-slice >string current-vocab
    add-vocab-todo ;

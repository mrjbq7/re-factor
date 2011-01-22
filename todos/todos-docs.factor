! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs help.markup help.syntax io
kernel sequences todos vocabs ;

IN: todos

: $all-todos ( element -- )
    drop "" all-todos [
        [ dup 2array $vocab-subsection ] [ $list ] bi*
    ] assoc-each ;

ARTICLE: "vocab-todos" "Vocabulary todos"
{ $all-todos } ;


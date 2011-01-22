
USING: accessors arrays assocs help.markup help.syntax kernel
sequences todos vocabs ;

IN: todos

: $all-todos ( element -- )
    drop "" child-vocab-todos [
        [ dup 2array { $vocab-subsection } prepend ]
        [ { $list } prepend ] bi*
        [ print-element ] bi@
    ] assoc-each ;

ARTICLE: "vocab-todos" "Vocabulary todos"
{ $all-todos } ;


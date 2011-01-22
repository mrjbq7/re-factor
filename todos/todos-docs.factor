
USING: arrays assocs help.markup help.syntax kernel sequences
todos vocabs ;

IN: todos

: $all-todos ( element -- )
    drop "" child-vocab-todos [
        [ $heading ] [ { $list } prepend print-element ] bi*
    ] assoc-each ;

ARTICLE: "vocab-todos" "Vocabulary todos"
{ $all-todos } ;


USING: combinators help.markup help.syntax ;

IN: utils

HELP: split1-when
{ $values { "seq" "a sequence" } { "quot" { $quotation "( elt -- ? )" } } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of an element for which " { $snippet "quot" } " gives a true output and outputs the pieces before and after the split." } ;

HELP: cond-case
{ $values { "assoc" "a sequence of quotation pairs and an optional quotation" } }
{ $description
    "Similar to " { $link case } ", this evaluates an " { $snippet "obj" } " according to the first quotation in each pair.  If any quotation returns true, calls the second quotation without " { $snippet "obj" } " on the stack."
    $nl
    "If there is no quotation that returns true, the default case is taken.  If the last element of " { $snippet "assoc" } " is a quotation, the quotation is called with " { $snippet "obj" } " on the stack.  Otherwise, a " { $link no-cond } " error is raised."
}
{ $examples
    { $example
        "USING: combinators io kernel math ;"
        "0 {"
        "    { [ 0 > ] [ \"positive\" ] }"
        "    { [ 0 < ] [ \"negative\" ] }"
        "    [ drop \"zero\" ]"
        "} cond-case print"
        "zero"
    }
} ;


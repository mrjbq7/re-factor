! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax ;

IN: n-partition

HELP: n-partition
{ $values
    { "amount" "a number of amount" }
    { "n" "a number of buckets" }
    { "seq" "a sequence" }
}
{ $description
    "Partition an integer evenly into 'n' buckets.  Returns a list "
    "of 'n' integers that sum to 'x'."
}
{ $examples
    { $example
        "USING: n-partition ;"
        "3 1 n-partition"
        "{ 3 }" }
    { $example
        "USING: n-partition ;"
        "3 3 n-partition"
        "{ 1 1 1 }" }
    { $example
        "USING: n-partition ;"
        "5 3 n-partition"
        "{ 2 1 2 }" }
    { $example
        "USING: n-partition ;"
        "3 5 n-partition"
        "{ 1 0 1 0 1 }" }
    { $example
        "USING: n-partition ;"
        "1000 7 n-partition"
        "{ 143 143 143 142 143 143 143 }" }
} ;


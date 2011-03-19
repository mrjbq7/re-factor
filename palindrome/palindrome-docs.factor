USING: palindrome help.markup help.syntax strings ;

IN: palindrome

HELP: palindrome?
{ $syntax "text palindrome?" }
{ $values { "text" "a string to be tested" } }
{ $description "Tests a string for palindrome-ness." }
{ $examples
    { $example
        "USING: palindrome ;"
        "\"racecar\" palindrome?"
        "t" }
} ;


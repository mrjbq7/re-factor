USING: help.markup help.syntax kernel strings ;
IN: mini-menu

HELP: <mini-menu-options>
{ $values { "options" mini-menu-options } }
{ $description "Creates options with no help, dispatch, or pre-menu quotation, and a comma delimiter." } ;

HELP: mini-menu-options
{ $class-description "Configuration for " { $link mini-menu* } ":"
    { $list
        { { $snippet "help" } ": an association from character keys to help strings, or f. Enables ? to print help in choice order. Missing descriptions are blank; the association is not modified." }
        { { $snippet "dispatch" } ": an association from character keys to quotations with effect ( choice -- repeat? ), or f. A quotation returning f exits; any other value repeats. Missing callbacks return the selected key immediately. Use t and f, not numeric 1 and 0: 0 is true in Factor." }
        { { $snippet "premenu" } ": a quotation with effect ( -- ), or f. Runs initially and after a callback requests another iteration, but not after help or invalid input." }
        { { $snippet "delim" } ": the string between displayed keys; defaults to a comma." }
    }
} ;

HELP: mini-menu
{ $values { "choices" string } { "prompt" string } { "choice/f" "a character or f" } }
{ $description "Displays a compact menu using the characters in choices, in their given order, and reads until a valid key is selected. Returns the character, or f at end of input. Choices must be nonempty. SPACE, ENTER, TAB, and ESC have readable labels." }
{ $notes "On Unix terminals connected to standard input, uses stty to disable canonical input and echo for each read, so ENTER is not required. Terminal settings are restored even on a Factor exception and before callbacks run. Other streams and platforms use read1 with their existing input mode." }
{ $examples
    { $unchecked-example "USING: mini-menu ;" "\"arq\" \"What do you want to do?\" mini-menu" }
} ;

HELP: mini-menu*
{ $values { "choices" string } { "prompt" string } { "options" mini-menu-options } { "choice/f" "a character or f" } }
{ $description "Like " { $link mini-menu } ", with optional help, callbacks, a pre-menu hook, and a custom delimiter. When help is enabled, ? is reserved and must not appear in choices. Callback exceptions propagate to the caller." }
{ $examples
    { $unchecked-example
        "USING: accessors io kernel mini-menu ;"
        "\"aq\" \"What shall we do?\" <mini-menu-options>"
        "    H{ { CHAR: a \"add\" } { CHAR: q \"quit\" } } >>help"
        "    H{ { CHAR: a [ drop \"Added!\" print t ] } } >>dispatch"
        "    [ \"Ready.\" print ] >>premenu"
        "    mini-menu*"
    }
} ;

ARTICLE: "mini-menu" "Compact single-key menus"
"Git-style menus inspired by Buddy Burden's Git-Like Menus article."
{ $subsections mini-menu <mini-menu-options> mini-menu-options mini-menu* } ;

ABOUT: "mini-menu"

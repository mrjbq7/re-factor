USING: accessors assocs io io.streams.string kernel mini-menu
namespaces sequences tools.test ;
IN: mini-menu.tests

{ CHAR: r "Choose [a,r,q] \nChoose [a,r,q] \n" } [
    "xr" [ [ "arq" "Choose" mini-menu ] with-string-writer ]
    with-string-reader
] unit-test

{ CHAR: q "Choose [q,?] \nq - quit\n? - print help\nChoose [q,?] \n" } [
    "?q" [ [
        "q" "Choose" <mini-menu-options>
            H{ { CHAR: q "quit" } } >>help mini-menu*
    ] with-string-writer ] with-string-reader
] unit-test

{ CHAR: ? "Choose [?] \n" } [
    "?" [ [ "?" "Choose" mini-menu ] with-string-writer ]
    with-string-reader
] unit-test

{ f "Choose [q] \n" } [
    "" [ [ "q" "Choose" mini-menu ] with-string-writer ]
    with-string-reader
] unit-test

{ CHAR: * "Choose [*,+] \n" } [
    "*" [ [ "*+" "Choose" mini-menu ] with-string-writer ]
    with-string-reader
] unit-test

{ CHAR: \n "Choose [SPACE|ENTER|TAB|ESC] \n" } [
    "\n" [ [
        " \n\t\e" "Choose" <mini-menu-options> "|" >>delim mini-menu*
    ] with-string-writer ] with-string-reader
] unit-test

SYMBOL: refreshes
SYMBOL: dispatched
SYMBOL: help-map

{ CHAR: q 2 CHAR: a t } [
    [
        V{ } clone refreshes set
        V{ } clone dispatched set
        H{ { CHAR: a "add" } { CHAR: q "quit" } } clone help-map set
        <mini-menu-options> help-map get >>help
            [ 1 refreshes get push ] >>premenu
            H{ { CHAR: a [ dispatched get push t ] } } >>dispatch
        "?xa?q" [ [ "aq" "Choose" rot mini-menu* ] with-string-writer ]
        with-string-reader drop
        refreshes get length dispatched get first
        CHAR: ? help-map get key? not
    ] with-scope
] unit-test

{ CHAR: q "Choose [q] \n" } [
    "q" [ [
        "q" "Choose" <mini-menu-options>
            H{ { CHAR: q [ drop f ] } } >>dispatch mini-menu*
    ] with-string-writer ] with-string-reader
] unit-test

[ "" "Choose" mini-menu ] [ empty-mini-menu? ] must-fail-with
[ "?" "Choose" <mini-menu-options> H{ } >>help mini-menu* ]
[ reserved-mini-menu-key? ] must-fail-with


USING: command-line io.streams.ansi namespaces sequences xmode.highlight ;

IN: factorize

: factorize. ( path -- )
    [ highlight. ] with-ansi ;

MAIN: [
    command-line get [ factorize. ] each
]

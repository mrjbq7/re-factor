USING: ascii combinators.short-circuit io kernel math
random ranges sequences splitting ;

IN: mispell

: misspell-word ( word -- word' )
    dup [ ",'.:;!?" member? not ] find-last drop 0 or
    dup 2 > [
        dupd head-slice dup [ Letter? ] all?
        [ rest-slice randomize ] when drop
    ] [ drop ] if ;

: misspell-line ( line -- line' )
    [ blank? ] split-when [ misspell-word ] map " " join ;

: misspell ( string -- string' )
    string-lines [ misspell-line ] map "\n" join ;

: misspell-main ( -- )
    """
    According to research at an English University, it doesn't matter
    in what order the letters in a word are, the only important thing is
    that the first and last letters be in the right places. The rest can
    be a total mess and you can still read it without problem. This is
    because the human mind does not read every letter by itself, but
    the word as a whole.
    """ misspell print ;

MAIN: misspell-main

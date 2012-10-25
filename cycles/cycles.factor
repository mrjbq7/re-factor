USING: assocs formatting io kernel math math.parser math.ranges
memoize sequences sequences.extras splitting unicode.categories ;

IN: cycles

: next-cycle ( x -- y )
    dup odd? [ 3 * 1 + ] [ 2 / ] if ;

: cycles ( n -- seq )
    [ dup 1 > ] [ [ next-cycle ] keep ] produce swap suffix ;

: cycle-length ( n -- m )
    1 [ over 1 > ] [ [ next-cycle ] [ 1 + ] bi* ] while nip ;

: max-cycle ( seq -- elt )
    [ dup cycle-length ] { } map>assoc [ second ] supremum-by ;

: max-cycle-value ( seq -- n ) max-cycle first ;

: max-cycle-length ( seq -- m ) max-cycle second ;

MEMO: fast-cycle-length ( n -- m )
    dup 1 > [ next-cycle fast-cycle-length 1 + ] [ drop 1 ] if ;

: run-cycles ( -- )
    [
        [ blank? ] split-when harvest first2
        [ string>number ] bi@ 2dup [a,b] max-cycle-length
        "%s %s %s\n" printf
    ] each-line ;

MAIN: run-cycles

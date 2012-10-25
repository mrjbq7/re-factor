USING: assocs formatting io kernel math math.parser math.ranges
memoize sequences sequences.extras splitting unicode.categories ;

IN: cycles

: next-cycle ( x -- y )
    dup odd? [ 3 * 1 + ] [ 2 / ] if ;

: cycles ( n -- seq )
    [ dup 1 > ] [ [ next-cycle ] keep ] produce swap suffix ;

: num-cycles ( n -- m )
    1 swap [ dup 1 > ] [ [ 1 + ] [ next-cycle ] bi* ] while drop ;

: max-cycle ( seq -- elt )
    [ [ num-cycles ] keep ] { } map>assoc [ first ] supremum-by ;

: max-cycles ( seq -- m ) max-cycle first ;

: max-cycle-value ( seq -- n ) max-cycle second ;

MEMO: fast-num-cycles ( n -- m )
    dup 1 > [ next-cycle fast-num-cycles 1 + ] [ drop 1 ] if ;

: run-cycles ( -- )
    [
        [ blank? ] split-when harvest first2
        [ string>number ] bi@ 2dup [a,b] max-cycles
        "%s %s %s\n" printf
    ] each-line ;

MAIN: run-cycles

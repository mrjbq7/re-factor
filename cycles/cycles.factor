USING: kernel math memoize sequences sequences.extras ;

IN: cycles

: next-cycle ( x -- y )
    dup odd? [ 3 * 1 + ] [ 2 / ] if ;

: cycles ( n -- seq )
    [ dup 1 > ] [ [ next-cycle ] keep ] produce swap suffix ;

: num-cycles ( n -- m )
    1 swap [ dup 1 > ] [ [ 1 + ] [ next-cycle ] bi* ] while drop ;

: max-cycles ( seq -- m )
    [ num-cycles ] map supremum ;

: max-cycle-value ( seq -- n )
    [ num-cycles ] supremum-by ;

MEMO: fast-num-cycles ( n -- m )
    dup 1 = [ drop 1 ] [ next-cycle fast-num-cycles 1 + ] if ;

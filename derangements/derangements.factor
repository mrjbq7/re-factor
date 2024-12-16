USING: arrays kernel math math.combinatorics
math.combinatorics.private math.factorials random ranges
sequences ;
FROM: sequences.private => nth-unsafe exchange-unsafe ;

IN: derangements

: derangement? ( indices -- ? )
    dup length <iota> [ = ] 2any? not ;

: <derangement-iota> ( seq -- <iota> )
    length subfactorial <iota> ; inline

: next-derangement ( seq -- seq )
    [ dup derangement? ] [ next-permutation ] do until ;

: derangements-quot ( seq quot -- seq quot' )
    [ [ <derangement-iota> ] [ length <iota> >array ] [ ] tri ] dip
    '[ drop _ next-derangement _ nths-unsafe @ ] ; inline

: each-derangement ( ... seq quot: ( ... elt -- ... ) -- ... )
    derangements-quot each ; inline

: map-derangements ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    derangements-quot map ; inline

: filter-derangements ( ... seq quot: ( ... elt -- ... ? ) -- ... newseq )
    selector [ each-derangement ] dip ; inline

: all-derangements ( seq -- seq' )
    [ ] map-derangements ;

: all-derangements? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    derangements-quot all? ; inline

: find-derangement ( ... seq quot: ( ... elt -- ... ? ) -- ... elt/f )
    '[ _ keep and ] derangements-quot map-find drop ; inline

: reduce-derangements ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd each-derangement ; inline

:: random-derangement-indices ( n -- indices )
    n <iota> >array :> seq
    f [
        dup :> v
        n 1 (a..b] [| j |
            j 1 + random :> p
            p v nth-unsafe j =
            [ t ] [ j p v exchange-unsafe f ] if
        ] any? v first zero? or
    ] [ drop seq clone ] do while ;

: random-derangement ( seq -- seq' )
    [ length random-derangement-indices ] [ nths-unsafe ] bi ;

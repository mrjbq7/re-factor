USING: arrays kernel math.combinatorics
math.combinatorics.private math.factorials sequences ;

IN: derangements

: derangement? ( indices -- ? )
    dup length <iota> [ = ] 2any? not ;

: <derangement-iota> ( seq -- <iota> )
    length subfactorial <iota> ; inline

: next-derangement ( seq -- seq )
    [ dup derangement? ] [ next-permutation ] do until ;

: derangements-quot ( seq quot -- seq quot' )
    [ [ <derangement-iota> ] [ length <iota> >array ] [ ] tri ] dip
    '[ drop _ [ _ nths-unsafe @ ] keep next-derangement drop ] ; inline

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

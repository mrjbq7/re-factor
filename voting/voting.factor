
USING: kernel locals math math.statistics sequences sorting ;

IN: voting

: count-votes ( votes -- total )
    [ first ] histogram-by sort-values ;

: choose-winner ( votes total -- winner/f )
    last first2 rot length 2/ > [ drop f ] unless ;

: remove-loser ( votes total -- newvotes )
    first first swap [ remove ] with map ;

: instant-runoff ( votes -- winner )
    dup count-votes 2dup choose-winner
    [ 2nip ] [ remove-loser instant-runoff ] if* ;

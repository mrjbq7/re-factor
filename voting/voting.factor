
USING: kernel locals math math.statistics sequences sorting ;

IN: voting

: count-votes ( votes -- total )
    [ first ] histogram-by sort-values ;

:: instant-runoff ( votes -- winner )
    votes count-votes dup last first2
    votes length 2/ > [ nip ] [
        drop first first
        votes [ remove ] with map
        instant-runoff
    ] if ;

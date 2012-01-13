
USING: accessors calendar kernel math math.ranges sequences ;

IN: friday-13th

: friday-13th? ( timestamp -- ? )
    [ day>> 13 = ] [ friday? ] bi and ;

: friday-13ths ( year -- seq )
    12 [0,b) [
        13 <date> dup friday? [ drop f ] unless
    ] with map sift ;

: all-friday-13ths ( start-year end-year -- seq )
    [a,b] [ friday-13ths ] map concat ;

: next-friday-13th ( timestamp -- date )
    dup day>> 13 >= [ 1 months time+ ] when 13 >>day
    [ dup friday? not ] [ 1 months time+ ] while ;

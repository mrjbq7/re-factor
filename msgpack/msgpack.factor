
USING: arrays combinators grouping io io.binary kernel math
math.bitwise math.order sequences ;

IN: msgpack

DEFER: read-msgpack

<PRIVATE

: read-array ( n -- obj )
    [ read-msgpack ] replicate ;

: read-map ( n -- obj )
    2 * read-array 2 group ;

: read-ext ( n -- obj )
    read be> [ 1 read signed-be> ] dip read 2array ;

PRIVATE>

SYMBOL: +msgpack-nil+

ERROR: unknown-format n ;

: read-msgpack ( -- obj )
    read1 {
        { [ dup 0xc0 = ] [ drop +msgpack-nil+ ] }
        { [ dup 0xc2 = ] [ drop f ] }
        { [ dup 0xc3 = ] [ drop t ] }
        { [ dup 0x00 0x7f between? ] [ ] }
        { [ dup 0xe0 mask? ] [ 1array signed-be> ] }
        { [ dup 0xcc = ] [ drop read1 ] }
        { [ dup 0xcd = ] [ drop 2 read be> ] }
        { [ dup 0xce = ] [ drop 4 read be> ] }
        { [ dup 0xcf = ] [ drop 8 read be> ] }
        { [ dup 0xd0 = ] [ drop 1 read signed-be> ] }
        { [ dup 0xd1 = ] [ drop 2 read signed-be> ] }
        { [ dup 0xd2 = ] [ drop 4 read signed-be> ] }
        { [ dup 0xd3 = ] [ drop 8 read signed-be> ] }
        { [ dup 0xca = ] [ drop 4 read be> bits>float ] }
        { [ dup 0xcb = ] [ drop 8 read be> bits>double ] }
        { [ dup 0xe0 mask 0xa0 = ] [ 0x1f mask read ] }
        { [ dup 0xd9 = ] [ drop read1 read "" like ] }
        { [ dup 0xda = ] [ drop 2 read be> read "" like ] }
        { [ dup 0xdb = ] [ drop 4 read be> read "" like ] }
        { [ dup 0xc4 = ] [ drop read1 read B{ } like ] }
        { [ dup 0xc5 = ] [ drop 2 read be> read B{ } like ] }
        { [ dup 0xc6 = ] [ drop 4 read be> read B{ } like ] }
        { [ dup 0xf0 mask 0x90 = ] [ 0x0f mask read-array ] }
        { [ dup 0xdc = ] [ drop 2 read be> read-array ] }
        { [ dup 0xdd = ] [ drop 4 read be> read-array ] }
        { [ dup 0xf0 mask 0x80 = ] [ 0x0f mask read-map ] }
        { [ dup 0xde = ] [ drop 2 read be> read-map ] }
        { [ dup 0xdf = ] [ drop 4 read be> read-map ] }
        { [ dup 0xd4 = ] [ drop 1 read-ext ] }
        { [ dup 0xd5 = ] [ drop 2 read-ext ] }
        { [ dup 0xd6 = ] [ drop 4 read-ext ] }
        { [ dup 0xd7 = ] [ drop 8 read-ext ] }
        { [ dup 0xd8 = ] [ drop 16 read-ext ] }
        { [ dup 0xc7 = ] [ drop read1 read-ext ] }
        { [ dup 0xc8 = ] [ drop 2 read be> read-ext ] }
        { [ dup 0xc9 = ] [ drop 4 read be> read-ext ] }
        [ unknown-format ]
    } cond ;

USING: combinators kernel locals math math.bitwise ;

IN: fast-factorial

:: part-product ( n m -- x )
    {
        { [ m n 1 + <= ] [ n ] }
        { [ m n 2 + = ] [ n m * ] }
        [
            n m + 2 /i dup even? [ 1 - ] when :> k
            n k k 2 + m [ part-product ] 2bi@ *
        ]
    } cond ;

:: factorial-loop ( n p r -- p' r' )
    n 2 > [
        n 2 /i :> mid
        mid p r factorial-loop
        [
            mid 1 + mid 1 bitand +
            n 1 - n 1 bitand + part-product *
        ] [ dupd * ] bi*
    ] [ p r ] if ;

: fast-factorial ( x -- n )
    [ 1 1 factorial-loop nip ] [ dup bit-count - ] bi shift ;

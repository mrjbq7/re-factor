
USING: ascii combinators kernel math math.parser sequences ;

IN: isbn

: digits ( str -- digits )
    [ digit? ] filter string>digits ;

: isbn-10-check ( digits -- n )
    0 [ 10 swap - * + ] reduce-index 11 mod ;

: isbn-13-check ( digits -- n )
    0 [ even? 1 3 ? * + ] reduce-index 10 mod ;

: valid-isbn? ( str -- ? )
    digits dup length {
        { 10 [ isbn-10-check ] }
        { 13 [ isbn-13-check ] }
    } case 0 = ;

: calc-isbn-10-check ( str -- check )
    digits isbn-10-check 11 swap - ;

: calc-isbn-13-check ( str -- check )
    digits isbn-13-check 10 swap - ;

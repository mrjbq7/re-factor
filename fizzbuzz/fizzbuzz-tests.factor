
USING: assocs fizzbuzz kernel io.streams.string ranges
sequences sets tools.test ;

IN: fizzbuzz

[ t ] [
    100 [1..b] {
        [ fizzbuzz1 ]
        [ fizzbuzz2 ]
        [ fizzbuzz3 ]
    } [ [ each ] curry with-string-writer ] with map
    unique assoc-size 1 =
] unit-test

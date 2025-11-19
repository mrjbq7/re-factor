! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs circular combinators combinators.extras
formatting io kernel lists lists.circular lists.lazy
math.functions present sequences utils ;

IN: fizzbuzz

: fizzbuzz1 ( n -- )
    {
        { [ dup 15 divisor? ] [ drop "FizzBuzz" ] }
        { [ dup 3  divisor? ] [ drop "Fizz" ] }
        { [ dup 5  divisor? ] [ drop "Buzz" ] }
        [ present ]
    } cond print ;

: fizzbuzz2 ( n -- )
    {
        { [ 15 divisor? ] [ "FizzBuzz" ] }
        { [ 3  divisor? ] [ "Fizz" ] }
        { [ 5  divisor? ] [ "Buzz" ] }
        [ present ]
    } cond-case print ;

: fizz ( n -- str/f )
    3 divisor? "Fizz" and ;

: buzz ( n -- str/f )
    5 divisor? "Buzz" and ;

: fizzbuzz3 ( n -- )
    dup [ fizz ] [ buzz ] bi "" append-as
    [ present ] [ nip ] if-empty print ;


: fizzbuzz? ( n -- test  )
    [ 3 divisor? ] [ 5 divisor? ] bi 2array ;

: fizzbuzz4 ( n -- )
    dup fizzbuzz? H{
        { t t } => "FizzBuzz"
        { t f } => "Fizz"
        { f t } => "Buzz"
    } at [ nip ] [ present ] if* print ;

: lfizzbuzz ( -- list )
    1 lfrom
    { "" "" "Fizz" } <circular>
    { "" "" "" "" "Buzz" } <circular>
    lzip [ concat ] lmap-lazy lzip
    [ first2 [ nip ] unless-empty ] lmap-lazy ;

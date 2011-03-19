! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals make math.ranges prettyprint sequences
unicode.case unicode.categories ;

IN: palindrome

: normalize ( str -- str' ) [ Letter? ] filter >lower ;

: palindrome? ( str -- ? ) normalize dup reverse = ;

:: each-subseq ( ... seq quot: ( ... x -- ... ) -- ... )
    seq length [0,b] [
        :> from
        from seq length (a,b] [
            :> to
            from to seq subseq quot call( x -- )
        ] each
    ] each ;

: palindromes ( str -- seq )
    [
        [ dup palindrome? [ , ] [ drop ] if ] each-subseq
    ] { } make ;

: main ( -- ) "racecar" palindrome? . ;

MAIN: main


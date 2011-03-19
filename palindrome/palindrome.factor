! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel prettyprint sequences unicode.case
unicode.categories ;

IN: palindrome

: normalize ( str -- str' ) [ Letter? ] filter >lower ;

: palindrome? ( str -- ? ) normalize dup reverse = ;

: main ( -- ) "racecar" palindrome? . ;

MAIN: main


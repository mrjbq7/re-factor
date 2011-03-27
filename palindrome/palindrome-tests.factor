! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: palindrome tools.test ;

[ f ] [ "hello" palindrome? ] unit-test
[ t ] [ "racecar" palindrome? ] unit-test
[ t ] [ "A man, a plan, a canal: Panama." palindrome? ] unit-test


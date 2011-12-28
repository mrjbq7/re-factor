! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: periodic-words tools.test ;

IN: periodic-words

[ t ] [ "Genius" periodic? ] unit-test
[ f ] [ "Factor" periodic? ] unit-test

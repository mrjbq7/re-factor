! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: plagiarism tools.test ;

IN: plagiarism

[ "this is a really LONG PIECE OF TEXT" ] [
    "this is a really long piece of text"
    { "this is a long piece of text" }
    4 detect-plagiarism
] unit-test

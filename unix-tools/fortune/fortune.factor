! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io io.encodings.utf8 io.files random sequences splitting
;

IN: unix-tools.fortune

: fortune. ( -- )
    "vocab:unix-tools/fortune/fortune.txt" utf8 file-lines
    { "%" } split random [ print ] each ;

MAIN: fortune.

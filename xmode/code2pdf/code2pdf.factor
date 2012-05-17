! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel io.encodings.utf8 io.files pdf pdf.streams
sequences xmode.highlight ;

IN: xmode.code2pdf

: code-to-pdf ( path -- )
    [ [ highlight. ] with-pdf-writer pdf>string ]
    [ ".pdf" append utf8 set-file-contents ] bi ;


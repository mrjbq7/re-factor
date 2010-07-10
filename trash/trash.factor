! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system vocabs.loader ;

IN: trash

HOOK: send-to-trash os ( path -- )

{
    { [ os macosx? ] [ "trash.macosx" ] }
    { [ os winnt? ] [ "trash.windows" ] }
    { [ os unix? ] [ "trash.unix" ] }
} cond require


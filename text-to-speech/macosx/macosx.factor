! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting io.launcher system text-to-speech ;

IN: text-to-speech.macosx

M: macosx speak-text ( str -- )
    "say \"%s\"" sprintf try-process ;

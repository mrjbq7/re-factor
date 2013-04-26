! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting google.translate io.launcher system
text-to-speech ;

IN: text-to-speech.windows

M: windows speak ( str -- )
    translate-tts
    "powershell -c (New-Object Media.SoundPlayer \"%s\").PlaySync();"
    sprintf try-process ;

! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting http.client io io.encodings.ascii
io.encodings.binary io.files io.files.unique io.launcher kernel
sequences system urls ;

IN: text-to-speech

! 1. "say"
! 2. festival, freetts, gnuspeech, espeech, flite, etc.
! 3. core-audio?
! 4. use google-translate-tts, download and play?

HOOK: speak os ( str -- )

M: macosx speak ( str -- )
    "say \"%s\"" sprintf try-process ;

M: linux speak ( str -- )
    "festival --tts" ascii [ print ] with-process-writer ;

M: windows speak ( str -- )
    "http://translate.google.com/translate_tts?tl=en" >url
    swap "q" set-query-param http-get nip
    temporary-file ".mp3" append
    [ binary set-file-contents ] [
        "powershell -c (New-Object Media.SoundPlayer \"%s\").PlaySync();"
        sprintf try-process
    ] bi ;

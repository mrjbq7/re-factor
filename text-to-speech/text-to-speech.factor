! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators strings system ui.operations vocabs ;

IN: text-to-speech

! 1. "say"
! 2. festival, freetts, gnuspeech, espeech, flite, etc.
! 3. core-audio?
! 4. use google-translate-tts, download and play?

HOOK: speak os ( str -- )

{
    { [ os macosx?  ] [ "text-to-speech.macosx"  ] }
    { [ os linux?   ] [ "text-to-speech.linux"   ] }
    { [ os windows? ] [ "text-to-speech.windows" ] }
} cond require

[ string? ] \ speak H{ } define-operation

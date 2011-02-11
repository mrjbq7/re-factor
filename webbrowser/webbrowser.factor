! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators system vocabs.loader ;

IN: webbrowser

HOOK: open-file os ( path -- )

HOOK: open-url os ( url -- )

{
    { [ os macosx? ] [ "webbrowser.macosx"  ] }
    { [ os unix?   ] [ "webbrowser.unix"    ] }
    { [ os winnt?  ] [ "webbrowser.windows" ] }
} cond require


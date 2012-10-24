USING: sequences system ;

IN: terminal

HOOK: (terminal-size) os ( -- dim )

{
    { [ os macosx?  ] [ "terminal.macosx"  ] }
    { [ os linux?   ] [ "terminal.linux"   ] }
    { [ os windows? ] [ "terminal.windows" ] }
} cond require

: terminal-size ( -- dim )
    (terminal-size) ;

: terminal-width ( -- width ) terminal-size first ;

: terimal-height ( -- height ) terminal-size second ;

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line io kernel namespaces sequences utils ;

IN: unix-tools.echo

: separator ( args -- args str )
    dup ?first "-n" = [ rest " \n" ] [ " " ] if ;

: echo-args ( args -- )
    separator join write nl ;

: run-echo ( -- )
    command-line get echo-args ;

MAIN: run-echo

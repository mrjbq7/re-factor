! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line io kernel namespaces sequences ;

IN: unix-tools.echo

: newline? ( args -- ? args' )
    [ first "-n" = ] keep over [ rest ] when ;

: echo-args ( args -- )
    newline? " " join write [ nl ] when ;

: run-echo ( -- )
    command-line get [ nl ] [ echo-args ] if-empty ;

MAIN: run-echo

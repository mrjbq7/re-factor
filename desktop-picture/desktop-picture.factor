! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors sequences system vocabs ;

IN: desktop-picture

HOOK: get-desktop-picture os ( -- path )

HOOK: set-desktop-picture os ( path -- )

"desktop-picture." os name>> append require

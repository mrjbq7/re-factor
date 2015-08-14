! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors sequences system vocabs ;

IN: desktop-picture

HOOK: get-desktop-picture os ( -- path )

HOOK: set-desktop-picture os ( path -- )

"desktop-picture." os name>> append require

! http://mail.python.org/pipermail/python-win32/2005-January/002893.html
! http://code.activestate.com/recipes/435877-change-the-wallpaper-under-windows/
! http://stackoverflow.com/questions/1977694/change-desktop-background
! http://stackoverflow.com/questions/2035657/what-is-my-current-desktop-environment/21213358#21213358

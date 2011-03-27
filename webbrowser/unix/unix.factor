! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: formatting io.launcher present system urls.encoding
webbrowser ;

IN: webbrowser.unix

M: unix open-file ( path -- )
    "gnome-open \"%s\"" sprintf try-process ;

M: unix open-url ( url -- )
    present url-encode open-file ;


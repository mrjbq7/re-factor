! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: cocoa.apple-script desktop-picture formatting io
io.encodings.utf8 io.launcher io.pathnames system ;

IN: desktop-picture.macos

M: macos set-desktop-picture
    absolute-path
    "tell application \"Finder\" to set desktop picture to POSIX file \"%s\""
    sprintf run-apple-script ;

M: macos get-desktop-picture
    {
        "osascript" "-e"
        "tell app \"Finder\" to get posix path of (get desktop picture as alias)"
    } utf8 [ readln ] with-process-reader ;

! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: desktop-picture io io.encodings.utf8 io.launcher kernel
sequences system ;

IN: desktop-picture.linux

M: linux set-desktop-picture
    {
        "gsettings"
        "set"
        "org.gnome.desktop.background"
        "picture-uri"
    } swap "file://" prepend suffix try-process ;

M: linux get-desktop-picture
    { "gsettings" "get" "org.gnome.desktop.background" }
    utf8 [ readln ] with-process-reader ;

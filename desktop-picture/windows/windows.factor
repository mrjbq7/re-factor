! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.data alien.strings desktop-picture
io.encodings.string io.encodings.utf16n kernel math system
windows.errors windows.kernel32 windows.types windows.user32 ;

IN: desktop-picture.windows

CONSTANT: SPI_SETDESKWALLPAPER 0x0014

CONSTANT: SPI_GETDESKWALLPAPER 0x0073

M: windows get-desktop-picture
    SPI_GETDESKWALLPAPER MAX_PATH dup 1 + WCHAR <c-array> [
        0 SystemParametersInfo win32-error<>0
    ] keep alien>native-string ;

M: windows set-desktop-picture
    [ SPI_SETDESKWALLPAPER 0 ] dip utf16n encode
    0 SystemParametersInfo win32-error<>0 ;

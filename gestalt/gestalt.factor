! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.data alien.syntax combinators core-foundation
formatting io.binary kernel math ;

IN: gestalt

<PRIVATE

TYPEDEF: SInt16 OSErr

TYPEDEF: UInt32 OSType

FUNCTION: OSErr Gestalt ( OSType selector, SInt32* response ) ;

PRIVATE>

: gestalt ( selector -- response )
    0 SInt32 <ref> [ Gestalt ] keep
    swap [ throw ] unless-zero le> ;

: system-version ( -- n )
    "sysv" be> gestalt ;

: system-version-major ( -- n )
    "sys1" be> gestalt ;

: system-version-minor ( -- n )
    "sys2" be> gestalt ;

: system-version-bugfix ( -- n )
    "sys3" be> gestalt ;

: system-version-string ( -- str )
    system-version-major
    system-version-minor
    system-version-bugfix
    "%s.%s.%s" sprintf ;

: system-code-name ( -- str )
    system-version {
        { [ dup HEX: 1070 >= ] [ "Lion"         ] }
        { [ dup HEX: 1060 >= ] [ "Snow Leopard" ] }
        { [ dup HEX: 1050 >= ] [ "Leopard"      ] }
        { [ dup HEX: 1040 >= ] [ "Tiger"        ] }
        { [ dup HEX: 1030 >= ] [ "Panther"      ] }
        { [ dup HEX: 1020 >= ] [ "Jaguar"       ] }
        { [ dup HEX: 1010 >= ] [ "Puma"         ] }
        { [ dup HEX: 1000 >= ] [ "Cheetah"      ] }
        [ "Unknown" ]
    } cond nip ;


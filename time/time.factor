! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: arrays calendar destructors io.sockets kernel math
pack sequences system ;

IN: time

: seconds-since-1900 ( -- n )
    now 1900 0 0 <date> time- duration>seconds >integer ;

: time-server ( -- )
    f 3700 <inet4> <datagram> [
        [
            [ receive nip ] keep
            [ seconds-since-1900 1array "I" pack ] 2dip
            [ send ] keep t
        ] loop drop
    ] with-disposal ;

: time-client ( -- seconds )
    B{ 0 } "127.0.0.1" 3700 <inet4>
    f 0 <inet4> <datagram> [
        [ send ] [ receive drop "I" unpack first ] bi
    ] with-disposal ;



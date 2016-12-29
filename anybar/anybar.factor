! Copyright (C) 2016 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io.encodings.ascii io.encodings.string io.sockets
namespaces sequences ;

IN: anybar

SYMBOL: anybar-host
"localhost" anybar-host set-global

SYMBOL: anybar-port
1738 anybar-port set-global

: anybar ( str -- )
    ascii encode
    anybar-host get resolve-host first
    anybar-port get with-port send-once ;

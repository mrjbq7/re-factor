! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: continuations formatting io.encodings.binary io.sockets
kernel make ranges sequences ;

IN: port-scan

: open-port? ( host port -- ? )
    <inet> [ binary [ t ] with-client ] [ 2drop f ] recover ;

: open-ports ( host -- seq )
    1024 [1..b] [
        [ 2dup open-port? [ , ] [ drop ] if ] each drop
    ] { } make ;

: scan-ports ( host -- )
    [ "Scanning %s...\n" printf ]
    [ open-ports [ "%d is open\n" printf ] each ]
    bi ;

: knock-ports ( host ports -- )
    [ open-port? drop ] with each ;

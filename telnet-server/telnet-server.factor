! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors kernel io io.encodings.binary io.servers
io.launcher namespaces ;

IN: telnet-server

! http://factor-language.blogspot.com/2008/06/https-support-in-httpserver-some-notes.html

: handle-telnet-client ( -- )
    <process>
        "/bin/sh -i" >>command
        input-stream get >>stdin
        output-stream get >>stdout
        +stdout+ >>stderr
    run-process drop ;

: <telnet-server> ( port -- server )
    binary <threaded-server>
        "telnet" >>name
        swap >>insecure
        [ handle-telnet-client ] >>handler ;

: start-telnet-server ( -- )
    10666 <telnet-server> start-server drop ;

MAIN: start-telnet-server


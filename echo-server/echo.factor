! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: kernel io io.encodings.ascii io.servers.connection
accessors ;

IN: echo

: echo-loop ( -- )
    readln [ write "\r\n" write flush echo-loop ] when* ;

: <echo-server> ( port -- server )
    ascii <threaded-server>
        swap >>insecure
        "echo.server" >>name
        [ echo-loop ] >>handler ;

: echod ( port -- )
    <echo-server> start-server ;

: echod-main ( -- ) 1234 echod ;

MAIN: echod-main



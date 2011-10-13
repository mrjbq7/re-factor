! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: accessors calendar formatting kernel io
io.encodings.ascii io.servers ;

IN: daytime

: <daytime-server> ( port -- server )
    ascii <threaded-server>
        swap >>insecure
        "daytime.server" >>name
        [ now "%c" strftime print flush ] >>handler ;

: daytimed ( port -- )
    <daytime-server> start-server ;

: daytimed-main ( -- ) 13 daytimed ;

MAIN: daytimed-main


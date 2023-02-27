
USING: accessors alien.c-types alien.data byte-arrays
classes.struct io io.encodings.binary io.encodings.string
io.encodings.utf8 io.servers kernel literals namespaces
sequences unix.ffi unix.types ;

IN: reference-server

:: reference-server ( -- )
    1024 <byte-array> :> buffer
    AF_INET SOCK_STREAM 0 socket :> server
    sockaddr-in malloc-struct
        AF_INET >>family
        0 >>addr
        15000 htons >>port :> address

    server address sockaddr-in heap-size bind drop

    [
        server 10 listen drop
        server address 0 socklen_t <ref> accept :> client
        client buffer 1024 0 recv
        buffer swap head-slice utf8 decode print flush
        client $[ "hello world\n" >byte-array ]
        dup length unix.ffi:write drop
        client close drop
        t
    ] loop

    server close drop ;

: reference-server2 ( -- )
    binary <threaded-server>
        "reference-server" >>name
        15000 >>insecure
        [
            1024 read-partial [
                [ utf8 decode print flush ] with-global
                $[ "hello world\n" >byte-array ] io:write flush
            ] when*
        ] >>handler
    start-server wait-for-server ;

MAIN: reference-server2

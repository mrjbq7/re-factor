USING: arrays continuations io io.backend.unix io.encodings.utf8
io.launcher io.ports kernel locals mini-menu.private namespaces
sequences splitting system unix.ffi ;
IN: mini-menu.unix

<PRIVATE

! Only change the terminal when the current stream is the real stdin.
: terminal-input? ( -- ? )
    [
        input-stream get underlying-handle
        dup stdin? [ drop t ] [ handle-fd 0 = ] if
    ]
    [ drop f ] recover
    [ 0 isatty 1 = ] [ f ] if ;

:: terminal-key ( -- key/f )
    { "stty" "-g" } utf8 [ read-contents ] with-process-reader
    [ "\r\n" member? ] trim :> mode
    [
        { "stty" "-icanon" "-echo" "min" "1" "time" "0" }
        try-process
        read1
    ] [ "stty" mode 2array try-process ] finally ;

PRIVATE>

M: unix read-menu-key
    terminal-input? [ terminal-key ] [ read1 ] if ;

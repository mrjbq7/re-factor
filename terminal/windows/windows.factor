USING: accessors classes.struct math terminal windows.kernel32
windows.types ;

IN: terminal.windows

M: windows (terminal-size)
    STD_OUTPUT_HANDLE GetStdHandle
    CONSOLE_SCREEN_BUFFER_INFO <struct>
    [ GetConsoleScreenBufferInfo drop ] keep srWindow>>
    [ [ Right>> ] [ Left>> ] bi - 1 + ]
    [ [ Bottom>> ] [ Top>> ] bi - 1 + ] bi ;

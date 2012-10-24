USING: accessors classes.struct terminal windows.kernel32
windows.types ;

IN: terminal.windows

<PRIVATE

STRUCT: COORD
{ X SHORT }
{ Y SHORT } ;

STRUCT: SMALL_RECT
{ Left SHORT }
{ Top SHORT }
{ Right SHORT }
{ Bottom SHORT } ;

STRUCT: CONSOLE_SCREEN_BUFFER_INFO
{ dwSize COORD }
{ dwCursorPosition COORD }
{ wAttributes WORD }
{ srWindow SMALL_RECT }
{ dwMaximumWindowSize COORD } ;

FUNCTION: BOOL GetConsoleScreenBufferInfo ( HANDLE hConsoleOutput, CONSOLE_SCREEN_BUFFER_INFO* lpConsoleScreenBufferInfo ) ;

PRIVATE>

HOOK: windows (terminal-size)
    STD_OUTPUT_HANDLE GetStdHandle
    CONSOLE_SCREEN_BUFFER_INFO <struct>
    [ GetConsoleScreenBufferInfo nip ] keep srWindow>>
    [ [ Right>> ] [ Left>> ] bi - 1 + ]
    [ [ Bottom>> ] [ Top>> ] bi - 1 + ] bi 2array ;

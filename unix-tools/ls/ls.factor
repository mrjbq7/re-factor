
USING: command-line namespaces io io.files io.pathnames
tools.files sequences kernel ;

IN: unix-tools.ls

: run-ls ( -- )
    command-line get [
        current-directory get directory.
    ] [
        dup length 1 = [ first directory. ] [
            [ [ nl write ":" print ] [ directory. ] bi ] each
        ] if
    ] if-empty ;

MAIN: run-ls

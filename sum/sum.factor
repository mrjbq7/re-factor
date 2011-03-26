! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line formatting io io.encodings.binary io.files
kernel math math.functions namespaces sequences ;

IN: sum

: sum-stream ( -- checksum blocks )
    0 0 [ [ sum nip + ] [ length + nip ] 3bi ] each-block
    [ 65535 mod ] [ 512 / ceiling ] bi* ;

: sum-stream. ( path -- )
    [ sum-stream ] dip "%d %d %s\n" printf ;

: sum-file. ( path -- )
    dup exists? [
        dup binary [ sum-stream. ] with-file-reader
    ] [ "%s: not found\n" printf ] if ;

: run-sum ( -- )
    command-line get [ "" sum-stream. ] [
        [ sum-file. ] each
    ] if-empty ;

MAIN: run-sum

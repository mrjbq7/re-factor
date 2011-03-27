! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USE: accessors
USE: assocs
USE: colors.constants
USE: colors.gray
USE: fonts
USE: hashtables
USE: help
USE: help.apropos
USE: help.pdf
USE: io
USE: io.encodings.utf8
USE: io.files
USE: io.styles
USE: kernel
USE: math
USE: pdf
USE: pdf.layout
USE: pdf.streams
USE: sequences

IN: pdf.examples

<PRIVATE

: foo-pdf ( pdf -- )
    "/Users/jbenedik/foo.pdf" utf8 set-file-contents ;

PRIVATE>

: test1-pdf ( -- )
    [ "Hello, world" print ] with-pdf-writer >pdf foo-pdf ;

: test2-pdf ( -- )
    [ "does “this” work?" print ] with-pdf-writer >pdf foo-pdf ;

: test3-pdf ( -- )
    [ "http" apropos ] with-pdf-writer >pdf foo-pdf ;

: test4-pdf ( -- )
    [
        10 iota [
            "Hello world\n"
            swap 10 / 1 <gray> foreground associate format
        ] each
    ] with-pdf-writer >pdf foo-pdf ;

USE: literals

: test5-pdf ( -- )
    [
        { $ sans-serif-font $ serif-font $ monospace-font } [
            name>> font-name associate
            { plain bold italic bold-italic } [
                [ name>> ] [
                    font-style associate pick assoc-union
                ] bi format nl
            ] each drop nl
        ] each
    ] with-pdf-writer >pdf foo-pdf ;

: test6-pdf ( -- )
    "/Users/jbenedik/Dev/re-factor/text-to-pdf/text-to-pdf.factor"
    utf8 file-contents text-to-pdf foo-pdf ;

: test7-pdf ( -- )
    [ "sequences" print-topic ] with-pdf-writer >pdf foo-pdf ;

: test8-pdf ( -- )
    [
        "does " write
        "this" COLOR: gray background associate format
        " work?" write
    ] with-pdf-writer >pdf foo-pdf ;

: test9-pdf ( -- )
    [
        "Some " write
        H{ { inset { 10 10 } } { page-color COLOR: light-gray } }
        [ "inset" write ] with-nesting
        " text" write
    ] with-pdf-writer >pdf foo-pdf ;

: test10-pdf ( -- )
    [
        { 12 18 24 72 }
        [ "Bigger" swap font-size associate format ] each
        nl
        { 12 18 24 72 }
        [ "Bigger" swap font-size associate format ] each
    ] with-pdf-writer >pdf foo-pdf ;



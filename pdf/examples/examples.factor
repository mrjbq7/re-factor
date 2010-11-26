

USE: accessors
USE: colors.constants
USE: colors.gray
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


: test3-pdf ( -- )
    [ "http" apropos ] with-pdf-writer >pdf foo-pdf ;

: test4-pdf ( -- )
    [
        10 iota [
            "Hello world\n"
            swap 10 / 1 <gray> foreground associate format
        ] each
    ] with-pdf-writer >pdf foo-pdf ;

: test5-pdf ( -- )
    [
        { plain bold italic bold-italic }
        [ [ name>> ] keep font-style associate format nl ] each
    ] with-pdf-writer >pdf foo-pdf ;

: test6-pdf ( -- )
    "/Users/jbenedik/Dev/re-factor/text-to-pdf/text-to-pdf.factor"
    utf8 file-contents text-to-pdf foo-pdf ;

: test7-pdf ( -- )
    [ "sequences" print-topic ] with-pdf-writer >pdf foo-pdf ;

: test8-pdf ( -- )
    [ "does “this” work?" print ] with-pdf-writer >pdf foo-pdf ;

: test9-pdf ( -- )
    [
        "does " write
        "this" COLOR: gray background associate format
        " work?" write
    ] with-pdf-writer >pdf foo-pdf ;

: test10-pdf ( -- )
    [
        H{ { inset { 10 10 } } { page-color COLOR: light-gray } }
        [ "Some inset text" write ] with-nesting nl
    ] with-pdf-writer >pdf foo-pdf ;




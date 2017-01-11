! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math sequences splitting unicode ;

IN: sanitize-paths

<PRIVATE

: filter-special ( str -- str' )
    [ "/\\?*:|\"<>" member? ] reject ;

: filter-control ( str -- str' )
    [ control? ] reject ;

: filter-blanks ( str -- str' )
    [ blank? ] split-when harvest " " join ;

: filter-windows-reserved ( str -- str' )
    dup >upper {
        "CON" "PRN" "AUX" "NUL" "COM1" "COM2" "COM3" "COM4"
        "COM5" "COM6" "COM7" "COM8" "COM9" "LPT1" "LPT2" "LPT3"
        "LPT4" "LPT5" "LPT6" "LPT7" "LPT8" "LPT9"
    } member? [ drop "file" ] when ;

: filter-empty ( str -- str' )
    [ "file" ] when-empty ;

: filter-dots ( str -- str' )
    dup first CHAR: . = [ "file" prepend ] when ;

PRIVATE>

: sanitize-path ( path -- path' )
    filter-special filter-control filter-blanks
    filter-windows-reserved filter-empty filter-dots
    255 short head ;

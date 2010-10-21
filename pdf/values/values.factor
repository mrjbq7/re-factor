! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs calendar colors colors.gray
combinators combinators.short-circuit fonts formatting
hashtables kernel make math math.parser sequences strings
xml.entities ;

IN: pdf.values

<PRIVATE

: escape-string ( str -- str' )
    H{
        { HEX: 08    "\\b"  }
        { HEX: 0c    "\\f"  }
        { CHAR: \n   "\\n"  }
        { CHAR: \r   "\\r"  }
        { CHAR: \t   "\\t"  }
        { CHAR: \\   "\\\\" }
        { CHAR: (    "\\("  }
        { CHAR: )    "\\)"  }
    } escape-string-by ;

PRIVATE>

GENERIC: pdf-value ( obj -- str )

M: number pdf-value number>string ;

M: t pdf-value drop "true" ;

M: f pdf-value drop "false" ;

M: color pdf-value
    [ red>> ] [ green>> ] [ blue>> ] tri
    "%f %f %f" sprintf ;

M: gray pdf-value
    gray>> dup dup "%f %f %f" sprintf ;

M: font pdf-value
    [
        "<<" ,
        "/Type /Font" ,
        "/Subtype /Type1" ,
        {
            [
                name>> {
                    { "sans-serif" [ "/Helvetica" ] }
                    { "serif"      [ "/Times"     ] }
                    { "monospace"  [ "/Courier"   ] }
                    [ " is unsupported" append throw ]
                } case
            ]
            [ [ bold?>> ] [ italic?>> ] bi or [ "-" append ] when ]
            [ bold?>> [ "Bold" append ] when ]
            [ italic?>> [ "Italic" append ] when ]
        } cleave
        "/BaseFont " prepend ,
        ">>" ,
    ] { } make "\n" join ;

M: timestamp pdf-value
    "%Y%m%d%H%M%S" strftime "D:" prepend ;

M: string pdf-value
    ! FIXME: escape chars (, ), unicode, etc.
    ! FIXME: lists of refs
    ! FIXME: gross check for "/"
    [ escape-string ]
    [ { [ empty? not ] [ first CHAR: / = ] } 1&& ]
    bi [ "(" ")" surround ] unless ;

M: sequence pdf-value
    [ "[" % [ pdf-value % " " % ] each "]" % ] "" make ;

M: hashtable pdf-value
    [
        "<<\n" %
        [ swap % " " % pdf-value % "\n" % ] assoc-each
        ">>" %
    ] "" make ;

! M: symbol pdf-value name>> "/" prepend ;


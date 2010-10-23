! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license


USING: accessors assocs colors io io.encodings.utf8 io.files
io.styles kernel lexer literals math math.parser namespaces
parser sequences xmode.catalog xmode.marker ;

IN: xmode.code2pdf

: >color ( n -- rgba )
    [ HEX: ff0000 bitand -16 shift ]
    [ HEX: 00ff00 bitand -8 shift ]
    [ HEX: 0000ff bitand ] tri
    [ 255 /f ] tri@ 1.0 <rgba> ;

CONSTANT: STYLES H{
    { "NULL"
        H{ { foreground HEX: 000000 $ >color } } }
    { "COMMENT1"
        H{ { foreground HEX: cc0000 $ >color } } }
    { "COMMENT2"
        H{ { foreground HEX: ff8400 $ >color } } }
    { "COMMENT3"
        H{ { foreground HEX: 6600cc $ >color } } }
    { "COMMENT4"
        H{ { foreground HEX: cc6600 $ >color } } }
    { "DIGIT"
        H{ { foreground HEX: ff0000 $ >color } } }
    { "FUNCTION"
        H{ { foreground HEX: 9966ff $ >color } } }
    { "INVALID"
        H{ { background HEX: ffffcc $ >color }
           { foreground HEX: ff0066 $ >color } } }
    { "KEYWORD1"
        H{ { foreground HEX: 006699 $ >color }
           { font-style bold } } }
    { "KEYWORD2"
        H{ { foreground HEX: 009966 $ >color }
           { font-style bold } } }
    { "KEYWORD3"
        H{ { foreground HEX: 0099ff $ >color }
           { font-style bold } } }
    { "KEYWORD4"
        H{ { foreground HEX: 66ccff $ >color }
           { font-style bold } } }
    { "LABEL"
        H{ { foreground HEX: 02b902 $ >color } } }
    { "LITERAL1"
        H{ { foreground HEX: ff00cc $ >color } } }
    { "LITERAL2"
        H{ { foreground HEX: cc00cc $ >color } } }
    { "LITERAL3"
        H{ { foreground HEX: 9900cc $ >color } } }
    { "LITERAL4"
        H{ { foreground HEX: 6600cc $ >color } } }
    { "MARKUP"
        H{ { foreground HEX: 0000ff $ >color } } }
    { "OPERATOR"
        H{ { foreground HEX: 000000 $ >color }
           { font-style bold } } }
}

CONSTANT: BASE H{
    { font-name "monospace" }
    { font-size 10 }
}

USE: locals
USE: pdf.layout

: pdfize-tokens ( tokens -- pdf )
    [
        [ str>> ] [ id>> ] bi
        [ name>> STYLES at ] [ f ] if*
        BASE assoc-union <text>
    ] map { $ <br> } append ;

: pdfize-line ( line-context line rules -- line-context' pdf )
    tokenize-line pdfize-tokens ;

: pdfize-lines ( lines mode -- pdf )
    [ f ] 2dip load-mode [ pdfize-line ] curry map nip concat ;

:: pdfize-stream ( path stream -- pdf )
    stream stream-lines
    [ "" ] [ path over first find-mode pdfize-lines ]
    if-empty ;

: pdfize-file ( path -- )
    dup utf8 [
        dup ".pdf" append utf8 [
            input-stream get pdfize-stream >pdf print
        ] with-file-writer
    ] with-file-reader ;



! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: command-line grouping io io.encodings.utf8 io.files
kernel math math.parser math.ranges namespaces regexp sequences
splitting unicode.case unicode.categories unicode.data ;

IN: plagiarism

: n-grams ( str n -- seq )
    [ [ blank? ] split-when ] [ <clumps> ] bi* ;

: n-gram>regexp ( seq -- regexp )
    [ [ Letter? not ] split-when "[\\W\\S]" join ] map
    "\\s+" join "(\\s|^)" "(\\s|$)" surround
    "i" <optioned-regexp> ;

: detect-plagiarism ( suspect source n -- suspect' )
    [ n-grams ] curry map concat [
        dupd n-gram>regexp [
            [ [a,b) ] dip [ ch>upper ] change-nths
        ] each-match
    ] each ;

: run-plagiarism ( -- )
    command-line get dup length 3 < [
        drop "USAGE: plagiarism N suspect.txt source.txt..." print
    ] [
        [ rest [ utf8 file-contents ] map unclip swap ]
        [ first string>number ] bi detect-plagiarism print
    ] if ;

MAIN: run-plagiarism

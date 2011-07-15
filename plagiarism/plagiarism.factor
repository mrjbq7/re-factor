! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: command-line grouping io io.encodings.utf8 io.files
kernel math math.parser math.ranges namespaces regexp sequences
sets splitting unicode.case unicode.categories unicode.data
utils ;

IN: plagiarism

: n-grams ( str n -- seq )
    [ [ blank? ] split-when harvest ] [ <clumps> ] bi* ;

: common-n-grams ( suspect sources n -- n-grams )
    [ n-grams ] curry dup [ map concat ] curry bi* intersect ;

: n-gram>regexp ( seq -- regexp )
    [ [ Letter? not ] split-when "[\\W\\S]" join ] map
    "\\s+" join "(\\s|^)" "(\\s|$)" surround
    "i" <optioned-regexp> ;

: upper-matches ( str regexp -- )
    [ [ [a,b) ] dip [ ch>upper ] change-nths ] each-match ;

: detect-plagiarism ( suspect sources n -- suspect' )
    [ dupd ] dip common-n-grams [
        dupd n-gram>regexp upper-matches
    ] each ;

: run-plagiarism ( -- )
    command-line get dup length 3 < [
        drop "USAGE: plagiarism N suspect.txt source.txt..." print
    ] [
        [ rest [ utf8 file-contents ] map unclip swap ]
        [ first string>number ] bi detect-plagiarism print
    ] if ;

MAIN: run-plagiarism

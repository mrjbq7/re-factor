! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line io kernel math.parser math.ranges namespaces
sequences ;

IN: unix-tools.seq

: usage ( -- )
    "Usage: seq first last" print ;

: seq ( a b -- )
    [a,b] [ number>string print ] each ;

: run-seq ( -- )
    command-line get dup length 2 = [
        first2 [ string>number ] bi@ seq
    ] [ drop usage ] if ;

MAIN: run-seq

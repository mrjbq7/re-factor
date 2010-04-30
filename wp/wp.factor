#! /usr/bin/env factor
! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs kernel io math math.parser 
prettyprint sequences splitting sorting ;

IN: wp

: count-words ( assoc string -- assoc' )
    " " split harvest [ over inc-at ] each ;

: sort-assoc ( assoc -- seq )
   >alist sort-values reverse ;

: print-results ( seq -- )
   [ number>string "    " glue print ] assoc-each ;

: wp ( -- ) 
    H{ } clone
    [ [ count-words ] each-line ]
    [ sort-assoc print-results ]
    bi drop ;

MAIN: wp


#! /usr/bin/env factor
! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs io math.parser math.statistics sequences splitting
sorting unicode ;

IN: wp

: count-words ( -- assoc )
    contents [ blank? ] split-when harvest histogram ;

: print-results ( seq -- )
   [ number>string "    " glue print ] assoc-each ;

: wp ( -- )
    count-words sort-values reverse print-results ;

MAIN: wp


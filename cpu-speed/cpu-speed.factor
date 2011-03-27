! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: cpu.x86.features kernel math tools.time ;

IN: cpu-speed

: busy-loop ( -- )
    100000000 [ 1 - dup 0 > ] loop drop ;

: instructions-per-nano ( -- n )
    [ [ busy-loop ] benchmark ] count-instructions swap / ;

: cpu-speed ( -- n )
    instructions-per-nano 1000000000.0 * ;

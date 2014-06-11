! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals math math.order math.parser math.statistics
namespaces sequences splitting strings ;

IN: spark

SYMBOL: ticks
"▁▂▃▄▅▆▇█" ticks set-global

:: spark-range ( seq min max -- str )
    max min - ticks get length 1 - / [ 1 ] when-zero :> unit
    seq [ min max clamp min - unit /i ticks get nth ] "" map-as ;

: spark-min ( seq min -- str )
    over supremum spark-range ;

: spark-max ( seq max -- str )
    [ dup infimum ] dip spark-range ;

GENERIC: spark ( seq -- str )

M: object spark dup minmax spark-range ;

M: string spark "," split [ string>number ] map spark ;

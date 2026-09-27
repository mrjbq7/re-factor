! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals math math.order math.parser math.statistics
namespaces sequences splitting strings ;

IN: sparkline

SYMBOL: ticks
"▁▂▃▄▅▆▇█" ticks set-global

:: sparkline-range ( seq min max -- str )
    max min - ticks get length 1 - / [ 1 ] when-zero :> unit
    seq [ min max clamp min - unit /i ticks get nth ] "" map-as ;

: sparkline-min ( seq min -- str )
    over supremum sparkline-range ;

: sparkline-max ( seq max -- str )
    [ dup infimum ] dip sparkline-range ;

GENERIC: sparkline ( seq -- str )

M: object sparkline dup minmax sparkline-range ;

M: string sparkline "," split [ string>number ] map sparkline ;

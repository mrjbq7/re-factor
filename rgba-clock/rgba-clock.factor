! Copyright (C) 2023 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors calendar calendar.format colors colors.contrast
fonts generalizations kernel math math.bitwise timers ui.gadgets
ui.gadgets.labels ui.pens.solid ;

IN: rgba-clock

: timestamp>rgba ( timestamp -- color/f )
    timestamp>unix-time >integer 32 bits
    24 2^ /mod 16 2^ /mod 8 2^ /mod
    [ 255 /f ] 4 napply <rgba> ;

<PRIVATE

: update-colors ( color label -- )
    [ [ contrast-text-color ] dip font>> foreground<< ]
    [ [ <solid> ] dip interior<< ] 2bi ;

PRIVATE>

TUPLE: rgba-clock < label timer ;

M: rgba-clock graft*
    [ timer>> start-timer ] [ call-next-method ] bi ;

M: rgba-clock ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

: <rgba-clock> ( -- gadget )
    "99:99:99" rgba-clock new-label
        monospace-font >>font
        dup '[
            _ now
            [ timestamp>hms >>string ]
            [ timestamp>rgba swap update-colors ] bi
        ] f 1 seconds <timer> >>timer ;

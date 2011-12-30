! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors calendar calendar.format calendar.model colors
fonts fry generalizations kernel math math.order models.arrow
namespaces ui.gadgets.labels ui.pens.solid ;

IN: second-color

<PRIVATE

: start-date ( -- timestamp )
    1941 9 9 <date> ; inline

: elapsed ( timestamp -- seconds )
    start-date time- duration>seconds >integer ;

PRIVATE>

: timestamp>rgba ( timestamp -- color/f )
    elapsed dup 0 32 2^ between? [
        24 2^ /mod 16 2^ /mod 8 2^ /mod
        [ 255 /f ] 4 napply <rgba>
    ] [ drop f ] if ;

<PRIVATE

: update-colors ( color label -- )
    [ font>> background<< ]
    [ [ <solid> ] dip [ interior<< ] [ boundary<< ] 2bi ]
    2bi ;

PRIVATE>

: <rgba-clock> ( -- gadget )
    f <label-control>
        time get over '[
            [ timestamp>rgba _ update-colors ]
            [ timestamp>hms ] bi
        ] <arrow> >>model
        "HH:MM:SS" >>string
        monospace-font >>font ;

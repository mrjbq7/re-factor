! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.data classes.struct kernel io
io.encodings.binary io.files math specialized-arrays ;

FROM: sequences => map-sum ;

IN: wavsum

PACKED-STRUCT: header
    { id char[4] }
    { totallength int }
    { wavefmt char[8] }
    { format int }
    { pcm short }
    { channels short }
    { frequency int }
    { bytes_per_second int }
    { bytes_by_capture short }
    { bits_per_sample short }
    { data char[4] }
    { bytes_in_data int } ;

: read-header ( -- header )
    header [ heap-size read ] [ memory>struct ] bi ;

SPECIALIZED-ARRAY: short

: sum-contents ( -- sum )
    contents short cast-array [ abs ] map-sum ;

: wavsum ( path -- header sum )
    binary [ read-header sum-contents ] with-file-reader ;

! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.endian
binary-search byte-arrays classes.struct combinators io
io.encodings.binary io.encodings.string io.encodings.utf8
io.files kernel literals locals math math.bitwise math.order
math.parser sequences specialized-arrays strings ;

IN: geo-tz

CONSTANT: deg-pixels 32

: <tile-key> ( size y x -- tile-key )
    [ 3 bits 28 shift ]
    [ 14 bits 14 shift ]
    [ 14 bits ] tri* bitor bitor ;

: >tile-key< ( tile-key -- size y x )
    [ -28 shift 3 bits ]
    [ -14 shift 14 bits ]
    [ 14 bits ] tri ;

<<
BE-PACKED-STRUCT: tile
    { key uint }
    { idx ushort } ;
>>

SPECIALIZED-ARRAY: tile

CONSTANT: zoom-levels $[
    6 iota [
        number>string
        "vocab:geo-tz/zoom" ".dat" surround
        binary file-contents tile cast-array
    ] map
]

<<
CONSTANT: #leaves 14110

BE-PACKED-STRUCT: one-bit-tile
    { idx0 ushort }
    { idx1 ushort }
    { bits ulonglong } ;
>>

CONSTANT: unique-leaves $[
    "vocab:geo-tz/leaves.dat" binary [
        #leaves [
            read1 {
                { CHAR: S [ { 0 } read-until drop utf8 decode ] }
                { CHAR: 2 [ one-bit-tile read-struct ] }
                { CHAR: P [ 128 read ] }
            } case
        ] replicate
    ] with-file-reader
]

CONSTANT: ocean-index 0xffff

:: lookup-leaf ( leaf x y tile-key -- zone/f )
    {
        { [ leaf string? ] [ leaf ] }
        { [ leaf one-bit-tile? ] [
            leaf bits>> y 3 bits 8 * x 3 bits + bit?
            [ leaf idx1>> ] [ leaf idx0>> ] if
            unique-leaves nth x y tile-key lookup-leaf ] }
        { [ leaf byte-array? ] [
            y 3 bits 8 * x 3 bits + 2 * :> i
            i leaf nth 8 shift i 1 + leaf nth +
            dup ocean-index = [ drop f ] [
                unique-leaves nth x y tile-key lookup-leaf
            ] if ] }
    } cond ;

:: lookup-zoom-level ( zoom-level x y tile-key -- zone/f )
    zoom-level [ key>> tile-key >=< ] search swap [
        dup key>> tile-key = [
            idx>> unique-leaves nth
            x y tile-key lookup-leaf
        ] [ drop f ] if
    ] [ drop f ] if ;

:: lookup-pixel ( x y -- zone )
    6 iota [| level |
        level zoom-levels nth
        x
        y
        level
        level 3 + neg :> n
        y n shift
        x n shift
        <tile-key>
        lookup-zoom-level
    ] map-find-last drop ;

:: lookup-zone ( lat lon -- zone )
    lon 180 + deg-pixels * 0 360 deg-pixels * 1 - clamp
    90 lat - deg-pixels * 0 180 deg-pixels * 1 - clamp
    [ >integer ] bi@ lookup-pixel ;

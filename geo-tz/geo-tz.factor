! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.endian
binary-search byte-arrays classes.struct combinators io
io.encodings.binary io.encodings.string io.encodings.utf8
io.files kernel literals locals math math.bitwise math.order
math.parser sequences specialized-arrays strings ;

IN: geo-tz

CONSTANT: deg-pixels 32

<<
BE-PACKED-STRUCT: tile
    { key uint }
    { idx ushort } ;
>>

SPECIALIZED-ARRAY: tile

CONSTANT: zoom-levels $[
    6 <iota> [
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

GENERIC# lookup-leaf 3 ( leaf x y tile-key -- zone/f )

M: string lookup-leaf 3drop ;

M:: one-bit-tile lookup-leaf ( leaf x y tile-key -- zone/f )
    leaf bits>> y 3 bits 3 shift x 3 bits bitor bit?
    [ leaf idx1>> ] [ leaf idx0>> ] if
    unique-leaves nth x y tile-key lookup-leaf ;

M:: byte-array lookup-leaf ( leaf x y tile-key -- zone/f )
    y 3 bits 3 shift x 3 bits bitor 2 * :> i
    i leaf nth 8 shift i 1 + leaf nth +
    dup ocean-index = [ drop f ] [
        unique-leaves nth x y tile-key lookup-leaf
    ] if ;

:: lookup-zoom-level ( zoom-level x y tile-key -- zone/f )
    zoom-level [ key>> tile-key >=< ] search swap [
        dup key>> tile-key = [
            idx>> unique-leaves nth
            x y tile-key lookup-leaf
        ] [ drop f ] if
    ] [ drop f ] if ;

:: lookup-pixel ( x y -- zone )
    6 <iota> [| level |
        level zoom-levels nth
        x
        y
        level
        level 3 + neg :> n
        y x [ n shift 14 bits ] bi@
        { 0 14 28 } bitfield
        lookup-zoom-level
    ] map-find-last drop ;

:: lookup-zone ( lat lon -- zone )
    lon 180 + deg-pixels * 0 360 deg-pixels * 1 - clamp
    90 lat - deg-pixels * 0 180 deg-pixels * 1 - clamp
    [ >integer ] bi@ lookup-pixel ;

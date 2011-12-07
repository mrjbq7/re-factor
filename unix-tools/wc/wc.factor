! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: destructors io io.encodings.binary io.files kernel math
sequences ;

IN: unix-tools.wc

: wc-file-lines ( path -- n ) ! 5.8 seconds
    binary file-lines length ;

: wc-each-line ( path -- n ) ! 3 seconds
    binary [
        0 [ drop 1 + ] each-line
    ] with-file-reader ;

: wc-read-until ( path -- n )
    binary [
        0 [ "\n" read-until [ drop 1 + ] dip ] loop
    ] with-file-reader ;

: wc-each-block ( path -- n ) ! 1.5 seconds
    binary [
        0 [ [ CHAR: \n = ] count + ] each-block
    ] with-file-reader ;

: wc-each-block-slice ( path -- n ) ! 1.0 seconds
    binary [
        0 [ [ CHAR: \n = ] count + ] each-block-slice
    ] with-file-reader ;

: wc-fast ( path -- n ) ! 0.245 seconds
    binary <file-reader> [
        0 swap [
            [ CHAR: \n = ] count +
        ] each-stream-block-slice
    ] with-disposal ;

: wc-faster ( path -- n ) ! 0.223 seconds
    binary <file-reader> [
        0 swap [
            [ CHAR: \n = ] count + >fixnum
        ] each-stream-block-slice
    ] with-disposal ;

USE: fry

: wc-fast-read-until ( path -- n ) ! 2.8 seconds
    binary <file-reader> [
        0 swap '[ "\n" _ stream-read-until [ drop 1 + ] dip ] loop
    ] with-disposal ;

USE: io.encodings.utf8
USE: io.launcher
USE: math.parser
USE: splitting

: wc-system ( path -- n )
    "wc -l " prepend utf8 [
        readln " " split harvest first string>number
    ] with-process-reader ;

USE: alien
USE: alien.data
USE: specialized-arrays
USE: math.vectors
USE: math.vectors.simd
SPECIALIZED-ARRAY: uchar-16

: aligned-slices ( seq -- head tail )
   dup length 15 bitnot bitand cut-slice ; inline

: wc-simd ( path -- n )
   [
       0 swap binary <file-reader> &dispose [
           aligned-slices [
               uchar-16 cast-array swap
               [ 10 uchar-16-with v= vcount + >fixnum ] reduce
           ] [ [ 10 = ] count + >fixnum ] bi*
       ] each-stream-block-slice
   ] with-destructors ;


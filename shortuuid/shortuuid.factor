! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math sequences ;

IN: shortuuid

CONSTANT: alphabet
"23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

: (encode-uuid) ( n -- n c )
    alphabet [ length /mod ] [ nth ] bi ;

: encode-uuid ( uuid -- shortuuid )
    [ dup 0 > ] [ (encode-uuid) ] "" produce-as nip ;

: (decode-uuid) ( n c -- n )
    alphabet index [ alphabet length * ] dip + ;

: decode-uuid ( shortuuid -- uuid )
    <reversed> 0 [ (decode-uuid) ] reduce ;

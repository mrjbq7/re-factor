! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: endian kernel math namespaces sequences strings uuid
uuid.private ;

IN: shortuuid

SYMBOL: alphabet
"23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
alphabet set-global

SYMBOL: legacy? ! compatible with pre-1.0.0 shortuuid

GENERIC: encode-uuid ( uuid -- shortuuid )

M: integer encode-uuid
    [ dup 0 > ] alphabet get
    '[ _ [ length /mod ] [ nth ] bi ]
    "" produce-as nip
    legacy? get [ reverse ] unless ;

M: string encode-uuid
    string>uuid encode-uuid ;

GENERIC: decode-uuid ( shortuuid -- uuid )

M: string decode-uuid
    legacy? get [ <reversed> ] when
    0 alphabet get dup
    '[ _ index [ _ length * ] dip + ] reduce
    uuid>string ;

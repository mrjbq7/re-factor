! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals math math.functions sequences ;

IN: pseudo-crypt

CONSTANT: PRIMES
{ 1 41 2377 147299 9132313 566201239 35104476161 2176477521929 }

CONSTANT: CHARS
"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

: base62 ( n -- string )
    [ dup 0 > ] [ 62 /mod CHARS nth ] "" produce-as reverse nip ;

:: udihash ( n chars -- string )
    chars PRIMES nth n * 62 chars ^ mod base62
    chars CHAR: 0 pad-head ;

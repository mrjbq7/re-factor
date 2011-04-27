! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USE: hashtables
USE: kernel
USE: peg.ebnf
USE: sequences
USE: strings
USE: make
USE: math
USE: io
USE: unicode.categories
USE: splitting
USE: regexp
USE: assocs
USE: combinators
USE: formatting


IN: txon

! http://www.hxa.name/txon/

<PRIVATE

: decode-value ( string -- string' )
    R" \\`" "`" re-replace ;

: parse-name ( string -- name remain )
    ":`" split1 [ decode-value ] dip ;

: find-` ( string -- string n/f )
    0 [
        CHAR: ` swap pick index-from [
            dup 1 - pick ?nth CHAR: \ = [ 1 + dup ] [ f ] if
        ] [ f f ] if*
    ] loop ;

DEFER: name=value

: parse-value ( string -- value remain )
    find-` [
        dup 1 - pick ?nth CHAR: : =
        [ drop name=value ] [ cut [ decode-value ] dip ] if
        1 tail [ blank? ] trim-head
    ] [ f ] if* ;

: name=value ( string -- term remain )
    [ blank? ] trim ":`" over subseq? [
        parse-name parse-value [ swap associate ] dip
    ] [ f ] if ;

PRIVATE>

: txon> ( string -- object )
    [
        [ dup empty? not ]
        [ name=value [ , ] dip ]
        while drop
    ] { } make dup length 1 = [ first ] when ;

<PRIVATE

: encode-value ( string -- string' )
    R" `" "\\`" re-replace ;

PRIVATE>

GENERIC: >txon ( object -- string )

M: sequence >txon
    [ >txon ] map "\n" join ;

M: assoc >txon
    >alist [ first2 >txon "%s:`%s`" sprintf ] map "\n" join ;

M: string >txon
    encode-value ;

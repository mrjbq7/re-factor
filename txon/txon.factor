! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs combinators combinators.short-circuit formatting
hashtables io kernel make math regexp sequences splitting
strings unicode.categories ;

IN: txon

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

DEFER: name/values

: parse-value ( string -- value remain )
    find-` [
        dup 1 - pick ?nth CHAR: : =
        [ drop name/values ] [ cut [ decode-value ] dip ] if
        1 tail [ blank? ] trim-head
    ] [ f ] if* ;

: name=value ( string -- term remain )
    [ blank? ] trim ":`" over subseq? [
        parse-name parse-value [ swap associate ] dip
    ] [ f ] if ;

: name/values ( string -- terms remain )
    [ dup { [ empty? not ] [ first CHAR: ` = not ] } 1&& ]
    [ name=value swap ] produce assoc-combine swap ;

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

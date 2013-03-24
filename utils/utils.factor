! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators db.types fry kernel lexer
locals macros math math.order math.ranges parser sequences
sequences.generalizations classes.tuple ;
FROM: sequences => change-nth ;

IN: utils

MACRO: cleave-array ( quots -- )
    [ '[ _ cleave ] ] [ length '[ _ narray ] ] bi compose ;

: until-empty ( seq quot -- )
    [ dup empty? ] swap until drop ; inline

SYNTAX: =>
    unclip-last scan-object 2array suffix! ;

<PRIVATE

USE: accessors
USE: io.pathnames
USE: namespaces
USE: source-files
USE: vocabs.loader
USE: vocabs.parser

: (include) ( parsed name -- parsed )
    [ file get path>> parent-directory ] dip
    ".factor" append append-path parse-file append ;

PRIVATE>

SYNTAX: INCLUDE: scan-token (include) ;

SYNTAX: INCLUDING: ";" [ (include) ] each-token ;

: of ( assoc key -- value ) swap at ;

USE: math.statistics
USE: sorting

: trim-histogram ( assoc n -- alist )
    [ sort-values reverse ] [ cut ] bi* values sum
    [ "Other" swap 2array suffix ] unless-zero ;

USE: quotations

USE: assocs.private

USE: grouping

: swap-when ( x y quot: ( x -- n ) quot: ( n n -- ? ) -- x' y' )
    '[ _ _ 2dup _ bi@ @ [ swap ] when ] call ; inline

: majority ( seq -- elt/f )
    [ f 0 ] dip [
        over zero? [ 2nip 1 ] [
            pick = [ 1 + ] [ 1 - ] if
        ] if
    ] each zero? [ drop f ] when ;

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ;

USE: math.parser

: humanize ( n -- str )
    dup 100 mod 11 13 between? [ "th" ] [
        dup 10 mod {
            { 1 [ "st" ] }
            { 2 [ "nd" ] }
            { 3 [ "rd" ] }
            [ drop "th" ]
        } case
    ] if [ number>string ] [ append ] bi* ;

USE: alien.c-types
USE: classes.struct
USE: io
USE: random

: remove-random ( seq -- elt seq' )
    [ length random ] keep [ nth ] [ remove-nth ] 2bi ;

USE: sets
USE: generic
USE: tools.annotations

<<
: wrap-method ( word before-quot after-quot -- )
    pick reset [ surround ] 2curry annotate ;
>>

<<
SYNTAX: BEFORE:
    scan-word scan-word lookup-method
    parse-definition [ ] wrap-method ;

SYNTAX: AFTER:
    scan-word scan-word lookup-method
    [ ] parse-definition wrap-method ;
>>

: (count-digits) ( n m -- n' )
    {
        { [ dup 10 < ] [ drop ] }
        { [ dup 100 < ] [ drop 1 fixnum+fast ] }
        { [ dup 1000 < ] [ drop 2 fixnum+fast ] }
        { [ dup 1000000000000 < ] [
            dup 100000000 < [
                dup 1000000 < [
                    dup 10000 < [
                        drop 3
                    ] [
                        100000 >= 5 4 ?
                    ] if
                ] [
                    10000000 >= 7 6 ?
                ] if
            ] [
                dup 10000000000 < [
                    1000000000 >= 9 8 ?
                ] [
                    100000000000 >= 10 9 ?
                ] if
            ] if fixnum+fast
        ] }
        [ [ 12 fixnum+fast ] [ 1000000000000 /i ] bi* (count-digits) ]
    } cond ; inline recursive

GENERIC: count-digits ( m -- n )

M: fixnum count-digits 1 swap (count-digits) ;
M: bignum count-digits 1 swap (count-digits) ;

: count-digits2 ( num radix -- n )
    [ log ] [ log ] bi* /i 1 + ; inline

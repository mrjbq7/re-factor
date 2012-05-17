! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators db.types fry kernel lexer
locals macros math math.order math.ranges parser sequences
sequences.generalizations ;
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

: set-slots ( assoc obj -- )
    '[ swap _ set-slot-named ] assoc-each ;

: from-slots ( assoc class -- obj )
    new [ set-slots ] keep ;

: of ( assoc key -- value ) swap at ;

USE: math.statistics
USE: sorting

: trim-histogram ( assoc n -- alist )
    [ sort-values reverse ] [ cut ] bi* values sum
    [ "Other" swap 2array suffix ] unless-zero ;

USE: quotations

MACRO: cond-case ( assoc -- )
    [
        dup callable? not [
            [ first [ dup ] prepose ]
            [ second [ drop ] prepose ] bi 2array
        ] when
    ] map [ cond ] curry ;

USE: assocs.private

: (assoc-merge) ( assoc1 assoc2 -- assoc1 )
    over [ push-at ] with-assoc assoc-each ;

: assoc-merge ( seq -- merge )
    H{ } clone [ (assoc-merge) ] reduce ;

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
USE: parser
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

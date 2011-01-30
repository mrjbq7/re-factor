! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators db.types fry kernel macros
math math.order parser sequences sequences.generalizations ;

IN: utils

MACRO: cleave-array ( quots -- )
    [ '[ _ cleave ] ] [ length '[ _ narray ] ] bi compose ;

: until-empty ( seq quot -- )
    [ dup empty? ] swap until drop ; inline

: ?first ( seq -- first/f )
    [ f ] [ first ] if-empty ; inline

: ?last ( seq -- last/f )
    [ f ] [ last ] if-empty ; inline

: split1-when ( ... seq quot: ( ... elt -- ... ? ) -- ... before after )
    dupd find drop [ 1 + cut ] [ f ] if* ; inline

SYNTAX: =>
    unclip-last scan-object 2array suffix! ;

SYNTAX: INCLUDE:
    scan-object parse-file append ;

: max-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ [ max ] keep eq? not ] curry most ; inline

: min-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ [ min ] keep eq? not ] curry most ; inline

: maximum ( seq quot: ( ... elt -- ... x ) -- elt )
    [ keep 2array ] curry
    [ [ first ] max-by ] map-reduce second ; inline

: minimum ( seq quot: ( ... elt -- ... x ) -- elt )
    [ keep 2array ] curry
    [ [ first ] min-by ] map-reduce second ; inline

: average ( seq -- n )
    [ sum ] [ length ] bi / ;

: set-slots ( assoc obj -- )
    '[ swap _ set-slot-named ] assoc-each ;

: from-slots ( assoc class -- obj )
    new [ set-slots ] keep ;

USE: math.statistics

: group-by ( seq quot: ( elt -- key ) -- assoc )
    dupd map zip [
        [ first2 ] [ push-at ] bi*
    ] sequence>hashtable ; inline

USE: sorting

: trim-histogram ( assoc n -- alist )
    [ >alist sort-values reverse ] [ cut ] bi*
    values sum [ "Other" swap 2array suffix ] unless-zero ;
    

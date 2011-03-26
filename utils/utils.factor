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

: set-slots ( assoc obj -- )
    '[ swap _ set-slot-named ] assoc-each ;

: from-slots ( assoc class -- obj )
    new [ set-slots ] keep ;

: group-by ( seq quot: ( elt -- key ) -- assoc )
    H{ } clone [
        [ push-at ] curry compose [ dup ] prepose each
    ] keep ; inline

USE: math.statistics
USE: sorting

: trim-histogram ( assoc n -- alist )
    [ >alist sort-values reverse ] [ cut ] bi*
    values sum [ "Other" swap 2array suffix ] unless-zero ;

USE: locals
USE: math.ranges

:: each-subseq ( ... seq quot: ( ... x -- ... ) -- ... )
    seq length [0,b] [
        :> from
        from seq length (a,b] [
            :> to
            from to seq subseq quot call( x -- )
        ] each
    ] each ;


USING: arrays combinators fry kernel macros math parser
sequences sequences.generalizations ;

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


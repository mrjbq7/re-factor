USING: accessors arrays assocs combinators io kernel locals
sequences strings system vocabs ;
IN: mini-menu

! http://blogs.perl.org/users/buddy_burden/2014/11/git-like-menus.html

TUPLE: mini-menu-options help dispatch premenu { delim initial: "," } ;

: <mini-menu-options> ( -- options ) mini-menu-options new ;

ERROR: empty-mini-menu ;
ERROR: reserved-mini-menu-key ;

<PRIVATE

HOOK: read-menu-key os ( -- key/f )
M: object read-menu-key read1 ;

: key-name ( key -- string )
    {
        { CHAR: \s [ "SPACE" ] }
        { CHAR: \n [ "ENTER" ] }
        { CHAR: \t [ "TAB" ] }
        { 27 [ "ESC" ] }
        [ 1string ]
    } case ;

:: menu-help ( choices help -- )
    choices [| key |
        key key-name write " - " write
        key help at "" or print
    ] each
    "? - print help" print ;

:: menu-prompt ( choices prompt options -- )
    prompt write " [" write
    choices >array options help>> [ CHAR: ? suffix ] when
    [ key-name ] map options delim>> join write
    "] " write flush ;

PRIVATE>

:: mini-menu* ( choices prompt options -- choice/f )
    choices empty? [ empty-mini-menu ] when
    options help>> [
        CHAR: ? choices member? [ reserved-mini-menu-key ] when
    ] when
    t :> refresh!
    f :> result!
    t :> running!
    [ running ] [
        refresh [ options premenu>> [ call( -- ) ] when* ] when
        f refresh!
        choices prompt options menu-prompt
        read-menu-key :> choice
        nl
        choice [
            choice CHAR: ? = options help>> and [
                choices options help>> menu-help
            ] [
                choice choices member? [
                    choice options dispatch>> at [
                        choice swap call( choice -- repeat? )
                    ] [ f ] if* [
                        t refresh!
                    ] [
                        choice result!
                        f running!
                    ] if
                ] when
            ] if
        ] [ f running! ] if
    ] while
    result ;

: mini-menu ( choices prompt -- choice/f )
    <mini-menu-options> mini-menu* ;

os unix? [ "mini-menu.unix" require ] when

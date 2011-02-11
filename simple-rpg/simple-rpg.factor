! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators formatting io kernel locals math
math.ranges random sequences ;

IN: simple-rpg

CONSTANT: first-names {
    "Destro"
    "Victo"
    "Mozri"
    "Fang"
    "Ovi"
    "Hell"
    "Syth"
    "End"
}

CONSTANT: last-names {
    "math"
    "rin"
    "sith"
    "icous"
    "ravage"
    "wrath"
    "ryn"
    "less"
}

: random-name ( -- str )
    first-names last-names [ random ] bi@ append ;

CONSTANT: attack-verbs {
    "slashes"
    "stabs"
    "smashes"
    "impales"
    "poisons"
    "shoots"
    "incinerates"
    "destroys"
}

CONSTANT: classes {
    "fighter"
    "mage"
    "cleric"
    "rogue"
}

TUPLE: character name class age str agi int gold hp max-hp ;

: alive? ( character -- ? ) hp>> 0 > ;

: full-stats ( character -- )
    {
        [ name>> "Name: %s\n" printf ]
        [ class>> "Class: %s\n" printf ]
        [ [ hp>> ] [ max-hp>> ] bi "HP: %d/%d\n" printf ]
        [ age>> "Age: %d\n" printf ]
        [
            [ str>> ] [ agi>> ] [ int>> ] tri
            "Str %d / Agi %d / Int %d\n" printf
        ]
        [ gold>> "Gold: %d\n" printf ]
    } cleave ;

: quick-stats ( character -- )
    [ name>> ] [ hp>> ] [ max-hp>> ] tri "%s (%d/%d)" printf ;

: <hero> ( -- character )
    character new
        "Valient" >>name
        "fighter" >>class
        22 >>age
        20 [ >>hp ] [ >>max-hp ] bi
        18 >>str
        14 >>agi
        12 >>int
        0 >>gold ;

: <enemy> ( -- character )
    character new
        random-name >>name
        classes random >>class
        12 200 [a,b] random >>age
        5 12 [a,b] random [ >>hp ] [ >>max-hp ] bi
        21 [1,b) random >>str
        21 [1,b) random >>agi
        21 [1,b) random >>int
        50 random >>gold ;

:: attack ( attacker defender -- )
    10 random :> damage
    attacker name>>
    attack-verbs random
    defender [ damage - ] change-hp name>>
    damage
    "%s %s %s for %d damage!\n" printf ;

:: battle ( hero enemy -- )
    "= Starting Battle =" print
    hero full-stats nl
    "vs." print nl
    enemy full-stats nl
    "An enemy approaches> " write read1 drop nl nl

    [ hero alive? enemy alive? and ] [
        hero quick-stats " / " write enemy quick-stats nl
        hero enemy attack
        enemy hero attack
        hero alive? [ "> " write read1 drop ] when nl
    ] while

    hero alive? [
        "Our hero survives to fight another battle! " write
        enemy gold>> "Won %d gold!\n" printf
        hero [ enemy gold>> + ] change-gold drop
    ] [
        hero gold>> "Our hero has fallen with %d gold! " printf
        "The world is covered in darkness once again." print
    ] if nl ;

: run-battle ( -- )
    <hero> [ dup alive? ] [ dup <enemy> battle ] while drop ;

MAIN: run-battle

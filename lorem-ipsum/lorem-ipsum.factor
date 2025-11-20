! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii command-line.parser io kernel literals make math
math.order namespaces qw random ranges sequences ;

IN: lorem-ipsum

CONSTANT: initial-paragraph "\
Lorem ipsum dolor sit amet, consectetur adipisicing \
elit, sed do eiusmod tempor incididunt ut labore et \
dolore magna aliqua. Ut enim ad minim veniam, quis \
nostrud exercitation ullamco laboris nisi ut aliquip ex \
ea commodo consequat. Duis aute irure dolor in \
reprehenderit in voluptate velit esse cillum dolore eu \
fugiat nulla pariatur. Excepteur sint occaecat cupidatat \
non proident, sunt in culpa qui officia deserunt mollit \
anim id est laborum."

CONSTANT: words qw{
    a ab accusamus accusantium ad adipisci alias aliquam aliquid
    amet animi aperiam architecto asperiores aspernatur
    assumenda at atque aut autem beatae blanditiis commodi
    consectetur consequatur consequuntur corporis corrupti culpa
    cum cumque cupiditate debitis delectus deleniti deserunt
    dicta dignissimos distinctio dolor dolore dolorem doloremque
    dolores doloribus dolorum ducimus ea eaque earum eius
    eligendi enim eos error esse est et eum eveniet ex excepturi
    exercitationem expedita explicabo facere facilis fuga fugiat
    fugit harum hic id illo illum impedit in incidunt inventore
    ipsa ipsam ipsum iste itaque iure iusto labore laboriosam
    laborum laudantium libero magnam magni maiores maxime minima
    minus modi molestiae molestias mollitia nam natus
    necessitatibus nemo neque nesciunt nihil nisi nobis non
    nostrum nulla numquam obcaecati odio odit officia officiis
    omnis optio pariatur perferendis perspiciatis placeat porro
    possimus praesentium provident quae quaerat quam quas quasi
    qui quia quibusdam quidem quis quisquam quo quod quos
    ratione recusandae reiciendis rem repellat repellendus
    reprehenderit repudiandae rerum saepe sapiente sed sequi
    similique sint sit soluta sunt suscipit tempora tempore
    temporibus tenetur totam ullam unde ut vel velit veniam
    veritatis vero vitae voluptas voluptate voluptatem
    voluptates voluptatibus voluptatum
}

: random-sentence ( -- str )
    2 ..= 5 random [
        words 3 ..= 12 random sample " " join
    ] replicate ", " join
    0 over [ ch>upper ] change-nth "?." random suffix ;

: random-paragraph ( -- str )
    2 ..= 4 random [ random-sentence ] replicate " " join ;

: random-paragraphs ( n -- str )
    <iota> [
        zero? [ initial-paragraph ] [ random-paragraph ] if
    ] map "\n" join ;

:: random-words ( n -- str )
    words length :> w
    [
        n [ words over w min sample % w [-] ] until-zero
    ] { } make ;

CONSTANT: OPTIONS {
    T{ option
        { name "--w" }
        { help "Generate some lorem ipsum words" }
        { #args 1 }
        { type integer }
    }
    T{ option
        { name "--s" }
        { help "Generate a lorem ipsum sentence" }
        { const t }
        { default f }
    }
    T{ option
        { name "--p" }
        { help "Generate a lorem ipsum paragraph" }
        { const t }
        { default f }
    }
}

MAIN: [
    OPTIONS [
        "w" get [ random-words print ] when*
        "s" get [ random-sentence print ] when
        "p" get [ random-paragraph print ] when
    ] with-options
]

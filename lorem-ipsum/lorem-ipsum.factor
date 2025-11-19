! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii command-line.parser io kernel literals make math
math.order namespaces qw random ranges sequences ;

IN: lorem-ipsum

CONSTANT: initial-paragraph $[
    qw{
        Lorem ipsum dolor sit amet, consectetur adipisicing
        elit, sed do eiusmod tempor incididunt ut labore et
        dolore magna aliqua. Ut enim ad minim veniam, quis
        nostrud exercitation ullamco laboris nisi ut aliquip ex
        ea commodo consequat. Duis aute irure dolor in
        reprehenderit in voluptate velit esse cillum dolore eu
        fugiat nulla pariatur. Excepteur sint occaecat cupidatat
        non proident, sunt in culpa qui officia deserunt mollit
        anim id est laborum.
    } " " join
]

CONSTANT: words qw{
    exercitationem perferendis perspiciatis laborum eveniet sunt
    iure nam nobis eum cum officiis excepturi odio consectetur
    quasi aut quisquam vel eligendi itaque non odit tempore
    quaerat dignissimos facilis neque nihil expedita vitae vero
    ipsum nisi animi cumque pariatur velit modi natus iusto
    eaque sequi illo sed ex et voluptatibus tempora veritatis
    ratione assumenda incidunt nostrum placeat aliquid fuga
    provident praesentium rem necessitatibus suscipit adipisci
    quidem possimus voluptas debitis sint accusantium unde
    sapiente voluptate qui aspernatur laudantium soluta amet quo
    aliquam saepe culpa libero ipsa dicta reiciendis nesciunt
    doloribus autem impedit minima maiores repudiandae ipsam
    obcaecati ullam enim totam delectus ducimus quis voluptates
    dolores molestiae harum dolorem quia voluptatem molestias
    magni distinctio omnis illum dolorum voluptatum ea quas quam
    corporis quae blanditiis atque deserunt laboriosam earum
    consequuntur hic cupiditate quibusdam accusamus ut rerum
    error minus eius ab ad nemo fugit officia at in id quos
    reprehenderit numquam iste fugiat sit inventore beatae
    repellendus magnam recusandae quod explicabo doloremque
    aperiam consequatur asperiores commodi optio dolor labore
    temporibus repellat veniam architecto est esse mollitia
    nulla a similique eos alias dolore tenetur deleniti porro
    facere maxime corrupti
}

CONSTANT: common-words qw{
    lorem ipsum dolor sit amet consectetur adipisicing elit sed
    do eiusmod tempor incididunt ut labore et dolore magna
    aliqua
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
    words length n min :> c
    [
        n [ dup 0 > ] [ c - words c sample % ] while drop
    ] { } make " " join ;

CONSTANT: OPTIONS {
    T{ option
        { name "--words" }
        { help "Returns lorem ipsum words" }
        { #args 1 }
        { type integer }
    }
    T{ option
        { name "--s" }
        { help "Returns lorem ipsum sentence" }
        { const t }
        { default f }
    }
    T{ option
        { name "--p" }
        { help "Returns lorem ipsum paragraph" }
        { const t }
        { default f }
    }
}

MAIN: [
    OPTIONS [
        "words" get [ random-words print ] when*
        "s" get [ random-sentence print ] when
        "p" get [ random-paragraph print ] when
    ] with-options
]


USING: accessors combinators continuations fry html.parser
html.parser.analyzer http.client images.http io io.styles kernel locals
math math.parser present regexp sequences sequences.extras sets.extras splitting
strings unicode urls ;

IN: beer-advocate

TUPLE: beer-link url name brewer location retired? ;

C: <beer-link> beer-link

TUPLE: beer-profile link ba-score bro-score style abv ;

C: <beer-profile> beer-profile

: beer-search-url ( query -- url )
    URL" https://www.beeradvocate.com/search/"
        swap "q" set-query-param ;

: html-text ( tags -- string )
    [ text>> ] map sift concat >string [ blank? ] trim ;

: link-path ( link -- path )
    first "href" attribute >url path>> ;

: beer-profile-link? ( link -- ? )
    link-path R/ \/beer\/profile\/[0-9]+\/[0-9]+\/?/ matches? ;

: brewery-link? ( link -- ? )
    link-path R/ \/beer\/profile\/[0-9]+\/?/ matches? ;

:: parse-beer-result ( tags -- beer/f )
    tags find-links :> links
    links [ beer-profile-link? ] find nip [| link |
        URL" https://www.beeradvocate.com/"
        link first "href" attribute derive-url
        "https" >>protocol present
        link html-text
        links [ brewery-link? ] find nip
        [ html-text ] [ "" ] if*
        tags [ name>> "span" = ] find-between-all
        [ html-text ] map
        [ >lower "retired" swap subseq? ] reject
        dup empty? [ drop "" ] [ last "| " ?head drop ] if
        tags html-text >lower "retired" swap subseq?
        <beer-link>
    ] [ f ] if* ;

: parse-beer-search ( html -- results )
    parse-html
    [ name>> { "li" "tr" } member? ] find-between-all
    [ parse-beer-result ] map sift
    [ url>> ] unique-by ;

: beer-search ( query -- results )
    beer-search-url http-get nip parse-beer-search ;

ERROR: too-many-beers results ;

GENERIC: lookup-beer ( obj -- profile )

M: string lookup-beer
    >lower dup beer-search
    dup length 1 = [
        first nip
    ] [
        [ [ name>> >lower = ] with find nip ] keep swap
        [ nip ] [ too-many-beers ] if*
    ] if lookup-beer ;

M: beer-link lookup-beer
    dup url>> http-get nip parse-html {
        [
            "ba-score" find-by-class-between
            [ text>> ] map-find drop string>number
        ]
        [
            "ba-bro_score" find-by-class-between
            [ text>> ] map-find drop string>number
        ]
        [
            find-links
            [ first "href" attribute "/beer/style/" head? ] find nip
            [ text>> ] map-find drop
        ]
        [
            dup [ "href" attribute "/beer/style/" head? ] find
            drop 5 + swap nth text>> " | &nbsp;" " " unsurround
        ]
    } cleave <beer-profile> ;

GENERIC: beer-image. ( obj -- )

M: object beer-image. lookup-beer beer-image. ;

M: beer-profile beer-image.
    link>> url>> "/" split harvest last
    '[
        _ "https://cdn.beeradvocate.com/im/beers/" ".jpg" surround
        http-image.
    ] [
        drop
        "https://cdn.beeradvocate.com/im/beers/no_beer_pic.jpg"
        http-image.
    ] recover ;

<PRIVATE

: row. ( name quot -- )
    '[ [ _ write ] with-cell _ with-cell ] with-row ; inline

PRIVATE>

GENERIC: beer. ( obj -- )

M: object beer. lookup-beer beer. ;

M: beer-profile beer.
    standard-table-style [
        {
            [ "Name" [ link>> [ name>> ] [ url>> ] bi write-object ] row. ]
            [ "Brewer" [ link>> brewer>> write ] row. ]
            [ "Location" [ link>> location>> write ] row. ]
            [ "BA SCORE" [ ba-score>> [ number>string write ] when* ] row. ]
            [ "THE BROS" [ bro-score>> [ number>string write ] when* ] row. ]
            [ "Style" [ style>> write ] row. ]
            [ "ABV" [ abv>> write ] row. ]
            [ "Image" [ beer-image. ] row. ]
            [ "Retired?" [ link>> retired?>> "YES" "NO" ? write ] row. ]
        } cleave
    ] tabular-output nl ;

: beers. ( query -- )
    beer-search [ beer. ] each ;

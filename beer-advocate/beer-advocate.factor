
USING: accessors combinators fry html.parser
html.parser.analyzer http.client images.http io io.styles kernel
math math.parser present sequences sequences.extras splitting
strings unicode.case urls ;

IN: beer-advocate

TUPLE: beer-link url name brewer location retired? ;

C: <beer-link> beer-link

TUPLE: beer-profile link ba-score bro-score style abv ;

C: <beer-profile> beer-profile

: beer-search-url ( query -- url )
    URL" http://www.beeradvocate.com/search/"
        swap "q" set-query-param
        "beer" "qt" set-query-param ;

: beer-search ( query -- results )
    beer-search-url http-get nip parse-html
    [ name>> "li" = ] find-between-all
    [
        find-all-links
        [ present "/beer/profile/" head? ] any?
    ] filter
    [
        [
            find-links first2
            [
                [
                    first "href" attribute
                    "http://www.beeradvocate.com" prepend
                ] keep
            ] dip
            [ [ text>> ] map-find drop ] bi@
        ]
        [
            [ name>> "span" = ] find-between-all dup length
            {
                { 1 [ first f ] }
                { 2 [ last t ] }
            } case
            [ [ text>> ] map-find drop "| " ?head drop ] dip
        ] bi
        <beer-link>
    ] map ;

ERROR: too-many-beers results ;

GENERIC: lookup-beer ( obj -- profile )

M: string lookup-beer
    >lower dup beer-search
    dup length 1 = [
        first nip
    ] [
        [ name>> >lower = ] with find nip
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
    "http://cdn.beeradvocate.com/im/beers/" ".jpg" surround
    http-image. ;

GENERIC: beer. ( obj -- )

M: object beer. lookup-beer beer. ;

M: beer-profile beer.
    standard-table-style [
        {
            [
                [
                    [ "Name" write ] with-cell
                    [ link>> [ name>> ] [ url>> ] bi write-object ] with-cell
                ] with-row
            ]
            [
                [
                    [ "Brewer" write ] with-cell
                    [ link>> brewer>> write ] with-cell
                ] with-row
            ]
            [
                [
                    [ "Location" write ] with-cell
                    [ link>> location>> write ] with-cell
                ] with-row
            ]
            [
                [
                    [ "BA SCORE" write ] with-cell
                    [ ba-score>> [ number>string write ] when* ] with-cell
                ] with-row
            ]
            [
                [
                    [ "THE BROS" write ] with-cell
                    [ bro-score>> [ number>string write ] when* ] with-cell
                ] with-row
            ]
            [
                [
                    [ "Style" write ] with-cell
                    [ style>> write ] with-cell
                ] with-row
            ]
            [
                [
                    [ "ABV" write ] with-cell
                    [ abv>> write ] with-cell
                ] with-row
            ]
            [
                [
                    [ "Image" write ] with-cell
                    [ beer-image. ] with-cell
                ] with-row
            ]
        } cleave
    ] tabular-output nl ;

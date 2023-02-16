! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii assocs colors combinators html.parser
html.parser.printer http.client images.http io
io.encodings.string io.encodings.utf8 io.styles json kernel make
sequences splitting urls wrap.strings ;

IN: duckduckgo

<PRIVATE

: duckduckgo-url ( query -- url )
    URL" http://api.duckduckgo.com"
        swap "q" set-query-param
        "json" "format" set-query-param
        "1" "pretty" set-query-param
        "1" "no_redirect" set-query-param
        "1" "no_html" set-query-param
        "1" "skip_disambig" set-query-param ;

: write-link ( title url -- )
    '[
        _ presented ,,
        COLOR: blue foreground ,,
    ] H{ } make format ;

: result. ( result -- )
    "Result" of [
        "<a href=\"" ?head drop "\">" split1 "</a>" split1
        [ swap >url write-object nl ]
        [ parse-html html-text ] bi*
        [ blank? ] trim-head "- " ?head drop
        [ 78 wrap-string print ] unless-empty nl
    ] when* ;

: abstract. ( results -- )
    dup "Heading" of [ drop ] [
        swap {
            [ "AbstractURL" of >url write-object nl ]
            [ "AbstractText" of 78 wrap-string print ]
            [ "AbstractSource" of "- " write print ]
        } cleave nl
    ] if-empty ;

PRIVATE>

: duckduckgo ( query -- results )
    duckduckgo-url http-get nip utf8 decode json> ;

: duckduckgo. ( query -- )
    duckduckgo {
        [ "Image" of [ "https://duckduckgo.com" prepend http-image. ] unless-empty ]
        [ abstract. ]
        [ "Results" of [ result. ] each ]
        [ "RelatedTopics" of [ result. ] each ]
    } cleave ;

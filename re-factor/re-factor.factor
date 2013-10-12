! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii assocs colors.constants fry html.parser
html.parser.printer http.client io io.streams.string io.styles
json.reader kernel memoize sequences sequences.extras splitting
strings urls wrap.strings ;

IN: re-factor

: re-factor-url ( str -- url )
    "http://re-factor.blogspot.com/" prepend ;

: posts-url ( -- url )
    "feeds/posts/default?alt=json&max-results=200" re-factor-url ;

MEMO: all-posts ( -- posts )
    posts-url http-get* json> { "feed" "entry" } [ of ] each ;

CONSTANT: post-style H{
    { foreground COLOR: blue }
}

: posts. ( -- )
    all-posts [
        [ "title" of "$t" of ] [ "link" of ] bi
        over '[ "title" of _ = ] find nip "href" of
        >url post-style [ write-object ] with-style nl
    ] each ;

CONSTANT: html-entities H{
    { "&quot;" "\"" }
    { "&lt;" "<" }
    { "&gt;" ">" }
    { "&amp;" "&" }
    { "&#39;" "'" }
}

: html-unescape ( str -- str' )
    html-entities [ replace ] assoc-each ;

: html-escape ( str -- str' )
    html-entities [ swap replace ] assoc-each ;

: post. ( n -- )
    all-posts nth
    [
        { "title" "$t" } [ of ] each
        [ print ] [ length CHAR: - <string> print ] bi nl
    ]
    [
        { "content" "$t" } [ of ] each
        parse-html [ html-text. ] with-string-writer
        html-unescape string-lines [
            [ blank? not ] cut-when
            [ write ] [ 70 wrap-string print ] bi*
        ] each
    ] bi ;

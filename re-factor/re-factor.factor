! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii assocs colors html.entities html.parser
html.parser.printer http.client io io.styles json.reader kernel
memoize sequences sequences.extras splitting strings urls
wrap.strings ;

IN: re-factor

: re-factor-url ( str -- url )
    "http://re-factor.blogspot.com/" prepend ;

: posts-url ( -- url )
    "feeds/posts/default?alt=json&max-results=300" re-factor-url ;

MEMO: all-posts ( -- posts )
    posts-url http-get nip json> { "feed" "entry" } [ of ] each ;

CONSTANT: post-style H{
    { foreground COLOR: blue }
}

: posts. ( -- )
    all-posts [
        [ "title" of "$t" of ] [ "link" of ] bi
        over '[ "title" of _ = ] find nip "href" of
        >url post-style [ write-object ] with-style nl
    ] each ;

: post-title. ( post -- )
    { "title" "$t" } [ of ] each
    [ print ] [ length CHAR: - <string> print ] bi nl ;

: post-content. ( post -- )
    { "content" "$t" } [ of ] each
    parse-html html-text html-unescape string-lines [
        [ blank? not ] cut-when
        [ write ] [ 70 wrap-string print ] bi*
    ] each ;

: post. ( n -- )
    all-posts nth [ post-title. ] [ post-content. ] bi ;

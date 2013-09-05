! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs colors.constants fry http.client io io.styles
json.reader kernel memoize sequences urls ;

IN: re-factor

: re-factor-url ( str -- url )
    "http://re-factor.blogspot.com/" prepend ;

: posts-url ( -- url )
    "feeds/posts/default?alt=json&max-results=200" re-factor-url ;

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

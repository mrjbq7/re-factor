! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs colors.constants combinators
formatting http.client io io.styles json.reader kernel sequences
urls utils wrap.strings ;

IN: google.search

<PRIVATE

CONSTANT: search-url
    URL" http://ajax.googleapis.com/ajax/services/search/web"

TUPLE: search-result cacheUrl GsearchResultClass visibleUrl
title content unescapedUrl url titleNoFormatting ;

PRIVATE>

: http-search ( query -- results )
    search-url
        "1.0" "v" set-query-param
        swap "q" set-query-param
        "8" "rsz" set-query-param
        "0" "start" set-query-param
    http-get nip json>
    { "responseData" "results" } [ swap at ] each
    [ \ search-result from-slots ] map ;

<PRIVATE

CONSTANT: heading-style H{
    { font-size 14 }
    { background COLOR: light-gray }
}

CONSTANT: title-style H{
    { foreground COLOR: blue }
}

CONSTANT: url-style H{
    { font-name "monospace" }
    { foreground COLOR: dark-green }
}

: write-heading ( str -- )
    heading-style format nl ;

: write-title ( str -- )
    title-style format nl ;

: write-content ( str -- )
    60 wrap-string print ;

: write-url ( str -- )
    dup >url url-style [ write-object ] with-style nl ;

PRIVATE>

: http-search. ( query -- )
    [ "Search results for '%s'" sprintf write-heading nl ]
    [ http-search ] bi [
        {
            [ titleNoFormatting>> write-title ]
            [ content>> write-content ]
            [ unescapedUrl>> write-url ]
        } cleave nl
    ] each ;

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators http.client io
json.reader kernel sequences urls utils ;

IN: google.search

CONSTANT: search-url
    URL" http://ajax.googleapis.com/ajax/services/search/web"

TUPLE: search-result cacheUrl GsearchResultClass visibleUrl
title content unescapedUrl url titleNoFormatting ;

: http-search ( query -- results )
    search-url
        "1.0" "v" set-query-param
        swap "q" set-query-param
        "8" "rsz" set-query-param
        "0" "start" set-query-param
    http-get nip json>
    { "responseData" "results" } [ swap at ] each
    [ \ search-result from-slots ] map ;

USE: formatting
USE: help.markup
USE: wrap.strings

: http-search. ( query -- )
    [ "Search results for '%s'" sprintf $heading ]
    [ http-search ] bi [
        {
            [ titleNoFormatting>> $subheading ]
            [ content>> 60 wrap-string print-element nl ]
            [ visibleUrl>> 1array $url ]
        } cleave
    ] each ;

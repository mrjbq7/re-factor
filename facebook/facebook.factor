! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs combinators http.client images.http
images.jpeg json.reader kernel sequences urls urls.encoding
urls.secure utils ;

IN: facebook

TUPLE: result application caption category created_time
description end_time from icon id likes link location message
name object_id picture properties source start_time to type
updated_time ;

TUPLE: search results next-url prev-url ;

<PRIVATE

: http-search ( url -- search )
    http-get nip json> {
        [ "data" swap at [ result from-slots ] map ]
        [ { "paging" "next" } [ swap at ] each ]
        [ { "paging" "previous" } [ swap at ] each ]
    } cleave \ search boa ;

: search-url ( query type -- url )
    URL" https://graph.facebook.com/search"
    swap "type" set-query-param
    swap "q" set-query-param ;

: (search) ( query type -- search )
    search-url http-search ;

PRIVATE>

: search ( str -- search ) f (search) ;

: search-posts ( str -- search ) "post" (search) ;

: search-users ( str -- search ) "user" (search) ;

: search-pages ( str -- search ) "page" (search) ;

: search-events ( str -- search ) "event" (search) ;

: search-groups ( str -- search ) "group" (search) ;

: next-page ( search -- search'/f )
    next-url>> [ http-search ] [ f ] if* ;

: prev-page ( search -- search'/f )
    prev-url>> [ http-search ] [ f ] if* ;

: picture. ( str -- )
    url-encode
    "https://graph.facebook.com/" "/picture" surround
    http-image. ;


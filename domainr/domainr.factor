! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs classes.tuple formatting http.client
json.reader kernel namespaces sequences urls ;

IN: domainr

! See: http://domainr.build/docs/authentication
SYMBOL: mashape-key

: domainr-url ( query -- url )
    URL" https://api.domainr.com/v2/search"
    swap "query" set-query-param
    mashape-key get "mashape-key" set-query-param ;

TUPLE: result domain host path subdomain availability
register_url ;

: domainr ( query -- data )
    domainr-url http-get nip json> "results" of
    [ result from-slots ] map ;

: domainr. ( query -- )
    domainr [
        [ subdomain>> ] [ path>> ] [ availability>> ] tri
        "%s%s - %s\n" printf
    ] each ;

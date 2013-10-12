! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs classes.tuple formatting http.client
json.reader kernel sequences urls utils ;

IN: domainr

: domainr-url ( query -- url )
    URL" https://domai.nr/api/json/search"
    swap "q" set-query-param ;

TUPLE: result domain host path subdomain availability
register_url ;

: domainr ( query -- data )
    domainr-url http-get* json> "results" of
    [ result from-slots ] map ;

: domainr. ( query -- )
    domainr [
        [ subdomain>> ] [ path>> ] [ availability>> ] tri
        "%s%s - %s\n" printf
    ] each ;

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs classes.tuple formatting http.client
json.reader kernel sequences urls urls.secure utils ;

IN: domainr

: domainr-url ( query -- url )
    URL" https://api.domainr.com/v1/search"
    swap "q" set-query-param
    "factor_lib" "client_id" set-query-param ;

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

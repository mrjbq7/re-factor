! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs formatting http.client json.reader
kernel sequences urls utils ;

IN: domainr

TUPLE: result domain host path subdomain availability
register_url ;

: domainr ( query -- data )
    URL" http://domai.nr/api/json/search"
        swap "q" set-query-param
    http-get nip json> "results" swap at
    [ result from-slots ] map ;

: domainr. ( query -- )
    domainr [
        [ subdomain>> ] [ path>> ] [ availability>> ] tri
        "%s%s - %s\n" printf
    ] each ;

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs http.client json.reader kernel namespaces
sequences urls utils ;

IN: bitly

SYMBOLS: bitly-api-user bitly-api-key ;

<PRIVATE

: <bitly-url> ( path -- url )
    "http://api.bitly.com/v3/" prepend >url
        bitly-api-user get-global "login" set-query-param
        bitly-api-key get-global "apiKey" set-query-param
        "json" "format" set-query-param ;

ERROR: bad-response json status ;

: check-status ( json -- json )
    dup "status_code" of 200 = [
        dup "status_txt" of
        bad-response
    ] unless ;

: json-data ( url -- json )
    http-get nip json> check-status "data" swap at ;

: get-short-url ( short-url path -- data )
    <bitly-url> swap "shortUrl" set-query-param json-data ;

: get-long-url ( long-url path -- data )
    <bitly-url> swap "longUrl" set-query-param json-data ;

PRIVATE>

: shorten-url ( url -- short-url )
    "shorten" get-long-url "url" swap at ;

: expand-url ( short-url -- url )
    "expand" get-short-url "expand" swap at
    first "long_url" swap at ;

: valid-user? ( user api-key -- ? )
    "validate" <bitly-url>
        swap "x_apiKey" set-query-param
        swap "x_login" set-query-param
    json-data "valid" swap at 1 = ;

: clicks ( short-url -- clicks )
    "clicks" get-short-url "clicks" swap at
    first "global_clicks" swap at ;

: referrers ( short-url -- referrers )
    "referrers" get-short-url "referrers" swap at ;

: countries ( short-url -- countries )
    "countries" get-short-url "countries" swap at ;

: clicks-by-minute ( short-url -- clicks )
    "clicks_by_minute" get-short-url "clicks_by_minute" swap at ;

: clicks-by-day ( short-url -- clicks )
    "clicks_by_day" get-short-url "clicks_by_day" swap at ;

: lookup ( long-urls -- short-urls )
    "lookup" <bitly-url>
        swap "url" set-query-param
    json-data "lookup" swap at [ "short_url" swap at ] map ;

: info ( short-url -- title )
    "info" get-short-url "info" swap at first "title" swap at ;

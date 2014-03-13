
USE: assocs
USE: formatting
USE: google
USE: http.client
USE: json.reader
USE: kernel
USE: locals
USE: math.parser
USE: namespaces
USE: sequences
USE: urls
USE: urls.secure
USE: xml
USE: xml.traversal

IN: google.buzz

<PRIVATE

: buzz-url ( path -- url )
    "https://www.googleapis.com/buzz/v1" prepend >url
        google-api-key get-global "key" set-query-param ;

: buzz-get ( url -- data )
    http-get nip json> "data" of ;

PRIVATE>

:: activities/count ( language url -- n )
    "/activities/count" buzz-url
        language "hl" set-query-param
        url "url" set-query-param
    http-get nip string>xml "total" deep-tag-named
    children>string string>number ;

: activities/list ( user-id scope -- xml )
    "/activities/%s/%s" sprintf buzz-url
    http-get nip string>xml ;

: activities/search ( query -- results )
    "/activities/search" buzz-url
        swap "q" set-query-param
        "json" "alt" set-query-param
    buzz-get "items" of ;

: activities/search-people ( query -- results )
    "/activities/search/@people" buzz-url
        swap "q" set-query-param
        "json" "alt" set-query-param
    buzz-get "entry" of ;

: people/get ( user-id -- xml )
    "/people/%s/@self" sprintf buzz-url
    http-get nip string>xml ;

: people/search ( query -- results )
    "/people/search" buzz-url
        swap "q" set-query-param
        "json" "alt" set-query-param
    buzz-get "entry" of ;



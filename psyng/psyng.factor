! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs hashtables http.client kernel locals
math math.parser namespaces sequences urls xml xml.traversal ;

IN: psyng

SYMBOL: psyng-api-key

CONSTANT: base-url "http://psydex.net/api"

: psyng-url ( path -- url )
    base-url prepend >url
        psyng-api-key get-global "api_key" set-query-param ;

<PRIVATE

: check-exception ( xml -- )
    body>> dup name>> main>> "exception_response" = [
        "message" deep-tag-named children>string throw
    ] [ drop ] if ;

PRIVATE>

: psyng-get ( url -- xml )
    http-get* string>xml [ check-exception ] keep ;


<PRIVATE

: tag-pairs ( xml tag -- seq )
    deep-tags-named [
        children-tags [ children>string ] { } map-as
    ] map ;

:: (catalog) ( type tag -- sources )
    "/catalog/" type append psyng-url
    psyng-get tag tag-pairs >hashtable ;

PRIVATE>

: sources ( -- assoc )
    "sources" "source" (catalog) ;

: intervals ( -- assoc )
    "intervals" "interval" (catalog) ;

: event-types ( -- assoc )
    "eventTypes" "event_type" (catalog) ;

: duration-units ( -- assoc )
    "durationUnits" "duration_unit" (catalog) ;

: periods ( -- assoc )
    "periods" "period" (catalog) ;

: shift-units ( -- assoc )
    "shiftUnits" "shift_unit" (catalog) ;

: sort-fields ( -- assoc )
    "sortFields" "sort_field" (catalog) ;

: sort-orders ( -- assoc )
    "sortOrders" "sort_order" (catalog) ;

: source-weights ( -- assoc )
    "sourceWeights" "source_weight" (catalog) ;

: stat-periods ( -- assoc )
    "statPeriods" "stat_period" (catalog) ;

: topic-classes ( -- assoc )
    "topicClasses" "topic_class" (catalog) ;

: topic-groups ( -- assoc )
    "topicGroups" "topic_group" (catalog) ;

: visibilities ( -- assoc )
    "visibilities" "visibility" (catalog) ;

: pql>time-series ( pql -- seq )
    "/timeSeries" psyng-url
        "18" "source_id" set-query-param
        "5" "interval_id" set-query-param
        "1267419600000" "begin" set-query-param
        "1299301200000" "end" set-query-param
        swap "pql" set-query-param
        "1" "concise_xml" set-query-param
    psyng-get  "dp" tag-pairs
    [ [ string>number ] map ] map ;

: content ( uuid -- string )
    "/content" psyng-url
        "retrieve" "action" set-query-param
        "21" "source_id" set-query-param
        "1268258403000" "pub_time" set-query-param
        swap "uuid" set-query-param
    psyng-get "text" deep-tags-named first
    children>string ;

<PRIVATE

: tag>assoc ( tag -- assoc )
    [
        dup children-tags [ children>string ] [
            nip [ tag>assoc ] map assoc-combine
        ] if-empty
    ] [ name>> main>> ] bi associate ;

:: (search) ( criteria type tag -- seq )
    "/search/" type append psyng-url
        criteria "criteria" set-query-param
    psyng-get tag deep-tags-named
    [ tag>assoc ] map ;

PRIVATE>

: search-topics ( criteria -- seq )
    "topics" "topic" (search) ;

: search-words ( criteria -- seq )
    "words" "word" (search) ;

: search-phrases ( criteria -- seq )
    "phrases" "phrase" (search) ;

: search-content ( -- ) ; ! FIXME

: events ( event-type-id -- seq )
    "/events" psyng-url
        swap "event_type_id" set-query-param
    psyng-get "event" deep-tags-named
    [ tag>assoc ] map ;

: topics ( id -- assoc )
    "/topics" psyng-url
        swap "id" set-query-param
    psyng-get "topic" deep-tag-named tag>assoc ;

: related-stocks ( symbol -- assoc ) ! FIXME
    "/relatedStocks" psyng-url
        swap "symbol" set-query-param
    psyng-get ;

: related-topics ( id -- assoc ) ! FIXME
    "/relatedTopics" psyng-url
        swap "id" set-query-param
    psyng-get "topic" deep-tag-named tag>assoc ;

: statistics ( id -- assoc )
    "/stats" psyng-url
        swap "id" set-query-param
    psyng-get "stat" deep-tag-named tag>assoc ;

: text-mining ( text -- seq )
    "/search/textMining" psyng-url
        swap "text" set-query-param
    psyng-get "coreferenced_topic" tag-pairs ;

: text-sentiment ( text -- assoc )
    "/sentiment" psyng-url
        swap "text" set-query-param
    psyng-get "sentiment" deep-tag-named tag>assoc ;

: url-sentiment ( url -- assoc )
    "/sentiment" psyng-url
        swap "url" set-query-param
    psyng-get "sentiment" deep-tag-named tag>assoc ;

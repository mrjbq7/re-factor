! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs classes.tuple http.client json.reader kernel
locals sequences urls ;

IN: geonames

<PRIVATE

: geonames-url ( path -- url )
    "http://ws.geonames.org" prepend >url
        "en" "lang" set-query-param ;

PRIVATE>

:: postal-code ( code country -- data )
    "/postalCodeLookupJSON" geonames-url
        code "postalcode" set-query-param
        country "country" set-query-param
    http-get* json> ;

TUPLE: country areaInSqKm bBoxEast bBoxNorth bBoxSouth bBoxWest
capital continent countryCode countryName currencyCode fipsCode
geonameId isoAlpha3 isoNumeric languages maxPostalCode
minPostalCode numPostalCodes population ;

: postal-code-countries ( -- countries )
    "/postalCodeCountryInfoJSON" geonames-url
    http-get* json> "geonames" of
    [ \ country from-slots ] map ;

: country-info ( name/f -- countries )
    "/countryInfo" geonames-url
        swap "country" set-query-param
        "JSON" "type" set-query-param
    http-get* json> "geonames" of
    [ \ country from-slots ] map ;

:: country-code ( lat lon -- data )
    "/countryCode" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
        "JSON" "type" set-query-param
    http-get* json> ;

:: country-subdivision ( lat lon -- data )
    "/countrySubdivisionJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: cities ( north south east west -- data )
    "/citiesJSON" geonames-url
        north "north" set-query-param
        south "south" set-query-param
        east "east" set-query-param
        west "west" set-query-param
    http-get* json> ;

:: timezone ( lat lon -- data )
    "/timezone" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: ocean ( lat lon -- data )
    "/oceanJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: neighborhood ( lat lon -- data )
    "/neighbourhoodJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: elevation-srtm3 ( lat lon -- data )
    "/srtm3JSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: elevation-astergdem ( lat lon -- data )
    "/astergdemJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: elevation-gtopo30 ( lat lon -- data )
    "/gtopo30JSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: find-nearby ( lat lon -- data )
    "/findNearbyJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

:: find-nearby-place-name ( lat lon -- data )
    "/findNearbyPlaceNameJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> ;

TUPLE: article countryCode distance elevation feature lang lat
lng population rank summary thumbnailImg title wikipediaUrl ;

:: wikipedia-nearby ( lat lon -- articles )
    "/findNearbyWikipediaJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get* json> "geonames" of
    [ \ article from-slots ] map ;

:: wikipedia-search ( query -- articles )
    "/wikipediaSearch" geonames-url
        query "q" set-query-param
        "10" "maxRows" set-query-param
        "JSON" "type" set-query-param
    http-get* json> "geonames" of
    [ \ article from-slots ] map ;

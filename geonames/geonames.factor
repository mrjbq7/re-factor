! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs classes.tuple http.json kernel locals namespaces
sequences urls ;

IN: geonames

SYMBOL: geonames-username

<PRIVATE

: geonames-url ( path -- url )
    "http://api.geonames.org" prepend >url
        geonames-username get [ "username" set-query-param ] when*
        "en" "lang" set-query-param ;

PRIVATE>

:: postal-code ( code country -- data )
    "/postalCodeLookupJSON" geonames-url
        code "postalcode" set-query-param
        country "country" set-query-param
    http-get-json nip ;

TUPLE: country north south countryName continentName isoAlpha3
    east west countryCode capital languages currencyCode
    continent fipsCode postalCodeFormat isoNumeric geonameId
    areaInSqKm population numPostalCodes minPostalCode
    maxPostalCode ;

: postal-code-countries ( -- countries )
    "/postalCodeCountryInfoJSON" geonames-url
    http-get-json nip "geonames" of
    [ country from-slots ] map ;

: country-info ( name/f -- countries )
    "/countryInfo" geonames-url
        swap "country" set-query-param
        "JSON" "type" set-query-param
    http-get-json nip "geonames" of
    [ country from-slots ] map ;

:: country-code ( lat lon -- data )
    "/countryCode" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
        "JSON" "type" set-query-param
    http-get-json nip ;

:: country-subdivision ( lat lon -- data )
    "/countrySubdivisionJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: cities ( north south east west -- data )
    "/citiesJSON" geonames-url
        north "north" set-query-param
        south "south" set-query-param
        east "east" set-query-param
        west "west" set-query-param
    http-get-json nip ;

:: timezone ( lat lon -- data )
    "/timezone" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: ocean ( lat lon -- data )
    "/oceanJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: neighborhood ( lat lon -- data )
    "/neighbourhoodJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: elevation-srtm3 ( lat lon -- data )
    "/srtm3JSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: elevation-astergdem ( lat lon -- data )
    "/astergdemJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: elevation-gtopo30 ( lat lon -- data )
    "/gtopo30JSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: find-nearby ( lat lon -- data )
    "/findNearbyJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

:: find-nearby-place-name ( lat lon -- data )
    "/findNearbyPlaceNameJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip ;

TUPLE: article countryCode distance elevation feature lang lat
lng population rank summary thumbnailImg title wikipediaUrl
geoNameId ;

:: wikipedia-nearby ( lat lon -- articles )
    "/findNearbyWikipediaJSON" geonames-url
        lat "lat" set-query-param
        lon "lng" set-query-param
    http-get-json nip "geonames" of
    [ article from-slots ] map ;

:: wikipedia-search ( query -- articles )
    "/wikipediaSearch" geonames-url
        query "q" set-query-param
        "10" "maxRows" set-query-param
        "JSON" "type" set-query-param
    http-get-json nip "geonames" of
    [ article from-slots ] map ;

! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators fry http.client io kernel 
quotations sequences xml xml.traversal ;

IN: ipinfodb

TUPLE: ip-info ip country-code country-name 
region-code region-name city zip-code
latitude longitude gmtoffset dstoffset ;

<PRIVATE

: find-tag ( tag name -- value )
    deep-tag-named children>string ; inline

: xml>ip-info ( xml -- info )
    [ ip-info new ] dip
    {
        [ "Ip" find-tag >>ip ]
        [ "CountryCode" find-tag >>country-code ]
        [ "CountryName" find-tag >>country-name ]
        [ "RegionCode" find-tag >>region-code ]
        [ "RegionName" find-tag >>region-name ]
        [ "City" find-tag >>city ]
        [ "ZipPostalCode" find-tag >>zip-code ]
        [ "Latitude" find-tag >>latitude ]
        [ "Longitude" find-tag >>longitude ]
        [ "Gmtoffset" find-tag >>gmtoffset ]
        [ "Dstoffset" find-tag >>dstoffset ]
    } cleave ;

PRIVATE>

: locate-my-ip ( -- info ) 
    "http://ipinfodb.com/ip_query.php" http-get
    string>xml xml>ip-info nip ;

: locate-ip ( ip -- info ) 
    "http://ipinfodb.com/ip_query.php?ip=" prepend http-get 
    string>xml xml>ip-info nip ;

: locate-ips ( ips -- infos )
    "," join "http://ipinfodb.com/ip_query2.php?ip=" prepend 
    http-get string>xml children-tags [ xml>ip-info ] { } map-as nip ;

: locate-ip2 ( ip/domain -- info ) 
    "http://ipinfodb.com/ip_query2.php?ip=" prepend http-get 
    string>xml xml>ip-info nip ;


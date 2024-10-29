! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs checksums checksums.md5
combinators concurrency.combinators formatting fry hex-strings
http.client images.http io io.encodings.string io.encodings.utf8
io.styles kernel locals make math math.constants math.functions
math.libm math.parser sequences sorting strings tools.time urls
urls.encoding xml xml.traversal ;

IN: speedtest

! TODO: 10 seconds http-timeout
! TODO: better threading, queue instead of parallel-map?

! http://xmodulo.com/2014/01/check-internet-speed-command-line-linux.html

<PRIVATE

TUPLE: config client times download upload ;

C: <config> config

: attr-map ( tag -- attrs )
    attrs>> [ [ main>> ] dip ] H{ } assoc-map-as ;

: speedtest-config ( -- config )
    "http://www.speedtest.net/speedtest-config.php"
    http-get nip utf8 decode string>xml {
        [ "client" deep-tag-named attr-map ]
        [ "times" deep-tag-named attr-map ]
        [ "download" deep-tag-named attr-map ]
        [ "upload" deep-tag-named attr-map ]
    } cleave <config> ;

: speedtest-servers ( -- servers )
    "http://www.speedtest.net/speedtest-servers.php"
    http-get nip string>xml
    "server" deep-tags-named [ attr-map ] map ;

: radians ( degrees -- radians ) pi * 180 /f ; inline

:: geo-distance ( lat1 lon1 lat2 lon2 -- distance )
    6371 :> radius ! km
    lat2 lat1 - radians :> dlat
    lon2 lon1 - radians :> dlon
    dlat 2 / sin sq dlon 2 / sin sq
    lat1 radians cos lat2 radians cos * * + :> a
    a sqrt 1 a - sqrt fatan2 2 * :> c
    radius c * ;

: lat/lon ( assoc -- lat lon )
    [ "lat" of ] [ "lon" of ] bi [ string>number ] bi@ ;

: server-distance ( server lat lon -- server )
    '[ lat/lon _ _ geo-distance "distance" ] keep
    [ set-at ] keep ;

: closest-servers-to ( lat lon -- servers )
    [ speedtest-servers ] 2dip '[ _ _ server-distance ] map
    [ "distance" of ] sort-with ;

: closest-servers ( -- servers )
    speedtest-config client>> lat/lon closest-servers-to ;

: (server-latency) ( server -- ms )
    "url" of >url URL" latency.txt" derive-url
    [ http-get nip "test=test\n" = ] benchmark 1,000,000 /f
    3,600,000 ? ;

: server-latency ( server -- server )
    [ (server-latency) "latency" ] keep [ set-at ] keep ;

: best-server ( -- server )
    closest-servers 5 index-or-length head
    [ server-latency ] parallel-map
    [ "latency" of ] sort-with first ;

: upload-data ( size -- data )
    9 - CHAR: 0 <string> "content1=" prepend ;

! TODO: upload 25 times each size

: (upload-speed) ( server -- Mbps )
    "url" of >url { 250,000 500,000 } [
        [
            upload-data [ swap http-put 2drop ] keep length
        ] with map-sum
    ] benchmark 1,000,000,000 /f / 8 * 1,000,000 / ;

: upload-speed ( server -- server )
    [ (upload-speed) "upload" ] keep [ set-at ] keep ;

: download-urls ( server -- urls )
    "url" of >url
    { 350 500 750 } ! 1000 1500 2000 2500 3000 3500 4000 }
    [ dup "random%sx%s.jpg" sprintf >url derive-url ] with map ;

: (download-speed) ( server -- Mbps )
    download-urls 4 swap <array> [
        [ [ http-get nip length ] map-sum ] parallel-map sum
    ] benchmark 1,000,000,000 /f / 8 * 1,000,000 / ;

: download-speed ( server -- server )
    [ (download-speed) "download" ] keep [ set-at ] keep ;

: run-speedtest ( -- server )
    "Selecting best server based on ping..." print flush
    best-server dup {
        [ "sponsor" of ]
        [ "name" of ]
        [ "distance" of ]
        [ "latency" of ]
    } cleave "Hosted by %s (%s) [%0.2f km]: %s ms\n" printf
    "Testing download speed" print flush download-speed
    dup "download" of "Download: %0.2f Mbit/s\n" printf
    "Testing upload speed" print flush upload-speed
    dup "upload" of "Upload: %0.2f Mbit/s\n" printf ;

: make-result ( server -- result )
    [
        {
            [ "download" of 1,000 * >integer "download" ,, ]
            [ "latency" of >integer "ping" ,, ]
            [ "upload" of 1,000 * >integer "upload" ,, ]
            [ drop "" "promo" ,, ]
            [ drop "pingselect" "startmode" ,, ]
            [ "id" of "recommendedserverid" ,, ]
            [ drop "1" "accuracy" ,, ]
            [ "id" of "serverid" ,, ]
            [
                [ "latency" of ]
                [ "upload" of 1,000 * ]
                [ "download" of 1,000 * ] tri
                "%d-%d-%d-297aae72" sprintf md5 checksum-bytes
                bytes>hex-string "hash" ,,
            ]
        } cleave
    ] { } make ;

: submit-result ( server -- result-id )
    make-result "http://www.speedtest.net/api/api.php"
    <post-request> [
        [
            "http://c.speedtest.net/flash/speedtest.swf"
            "referer"
        ] dip header>> set-at
    ] keep http-request nip query>assoc "resultid" of ;

PRIVATE>

: speedtest ( -- )
    run-speedtest submit-result "Share results: " write
    "http://www.speedtest.net/result/%s.png" sprintf
    [ dup >url write-object nl ] [ http-image. ] bi ;

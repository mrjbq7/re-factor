! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

IN: repopular

USING: assocs assocs.extras http.client json.reader kernel
sequences utils ;

: the-yahoo-way ( -- seq )
    "http://query.yahooapis.com/v1/public/yql?q=use%20'http%3A%2F%2Fyqlblog.net%2Fsamples%2Fdata.html.cssselect.xml'%20as%20data.html.cssselect%3B%20select%20*%20from%20data.html.cssselect%20where%20url%3D%22repopular.com%22%20and%20css%3D%22div.pad%20a%22&format=json&diagnostics=true&callback="
    http-get nip json> { "query" "results" "results" "a" }
    deep-at [ "href" swap at ] map
    [ "http://github.com" head? ] filter ;

USING: accessors assocs html.parser http.client kernel
sequences ;

: the-other-way ( -- seq )
    "http://repopular.com" http-get nip parse-html
    [ [ name>> "aside" = ] find drop ]
    [ [ name>> "aside" = ] find-last drop ]
    [ <slice> ] tri
    [ name>> "a" = ] filter
    [ attributes>> "href" swap at ] map
    [ "http://github.com" head? ] filter ;

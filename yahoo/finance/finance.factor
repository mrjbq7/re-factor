! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: csv http.client kernel sequences strings urls ;

IN: yahoo.finance

: historical-prices ( symbol -- csv )
    "http://ichart.finance.yahoo.com/table.csv" >url
       swap "s" set-query-param
       "0" "a" set-query-param
       "1" "b" set-query-param
       "2009" "c" set-query-param
    http-get* string>csv ;

: quotes ( symbols -- csv )
    "http://finance.yahoo.com/d/quotes.csv" >url
        swap "+" join "s" set-query-param
        "sbal1v" "f" set-query-param
    http-get* >string string>csv
    { "Symbol" "Bid" "Ask" "Last" "Volume" } prefix ;

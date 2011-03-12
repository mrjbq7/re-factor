! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: csv http.client kernel sequences strings urls ;

IN: yahoo.finance

: historical-prices ( symbol -- csv )
    "http://ichart.finance.yahoo.com/table.csv" >url
       swap "s" set-query-param
       "0" "a" set-query-param
       "29" "b" set-query-param
       "2" "d" set-query-param
       "12" "e" set-query-param
       "2011" "f" set-query-param
       "2001" "c" set-query-param
    http-get nip string>csv ;

: quotes ( symbols -- csv )
    "http://finance.yahoo.com/d/quotes.csv" >url
        swap "+" join "s" set-query-param
        "baclv" "f" set-query-param
    http-get nip >string string>csv ;

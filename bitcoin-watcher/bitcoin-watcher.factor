
USING: accessors assocs classes.tuple combinators
concurrency.combinators generalizations hashtables
help.stylesheet http.client io io.styles json kernel math.parser
namespaces sequences strings ;

IN: bitcoin-watcher

TUPLE: site name url currency ;

TUPLE: bitcoin-url name url currency ;

CONSTANT: bitcoin-urls {
    { T{ site f "bitstamp" "http://www.bitstamp.net" "$" } "https://www.bitstamp.net/api/ticker" }
    { T{ site f "btc100" "https://btc100.org" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=btc100Ticker&suffix=0.16103304247371852" }
    { T{ site f "btcchina" "https://www.btcchina.com" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=btcchinaTicker&suffix=0.3849131213501096" }
    { T{ site f "btctrade" "http://www.btctrade.com" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=btctradeTicker&suffix=0.1531917753163725" }
    { T{ site f "chbtc" "https://www.chbtc.com" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=chbtcTicker&suffix=0.5108873315621167" }
    { T{ site f "futures796" "http://bitcoinwisdom.com/markets/796/futures" "$" } "http://www.btc123.com/e/interfaces/tickers.php?type=796futuresTicker&suffix=0.38433733163401484" }
    { T{ site f "fxbtc" "http://www.fxbtc.com" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=fxbtcTicker&suffix=0.19148686854168773" }
    { T{ site f "mtgox" "https://mtgox.com" "$" } "http://www.btc123.com/e/interfaces/tickers.php?type=MtGoxTicker&suffix=0.8636577818542719" }
    { T{ site f "okcoin" "https://www.okcoin.com" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=okcoinTicker&suffix=0.7636065774131566" }
}

TUPLE: quote bid ask high low last volume ;

C: <quote> quote

<PRIVATE

: (bitcoin-quotes) ( -- json )
    bitcoin-urls [ http-get nip "" like json> ] parallel-assoc-map ;

: of* ( assoc seq -- assoc' )
    [ over at* [ [ nip ] [ drop ] if ] keep ] find 2drop ;

: ?value ( obj -- obj' )
    dup hashtable? [ "value" of ] when
    dup string? [ string>number ] when ;

PRIVATE>

: bitcoin-quotes ( -- quotes )
    (bitcoin-quotes) [
        { "data" "ticker" } of* {
            [ { "bid" "buy" } of* ]
            [ { "ask" "sell" } of* ]
            [ "high" of ]
            [ "low" of ]
            [ { "last" "last_rate" } of* ]
            [ { "vol" "volume" } of* ]
        } cleave [ ?value ] 6 napply <quote>
    ] assoc-map ;


<PRIVATE

: write-site ( site -- )
    [ name>> ] [ url>> ] bi [ write-object ] with-cell ;

: write-price ( site quote -- )
    [ currency>> ] [ last>> ] bi* number>string append
    [ write ] with-cell ;

: write-volume ( quote -- )
    volume>> number>string [ write ] with-cell ;

PRIVATE>

: bitcoin-quotes. ( -- )
    table-style get [
        bitcoin-quotes [
            [
                [ drop write-site ]
                [ write-price ]
                [ write-volume drop ]
                2tri
            ] with-row
        ] assoc-each
    ] tabular-output nl ;

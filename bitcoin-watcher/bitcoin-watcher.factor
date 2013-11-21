
USING: accessors assocs classes.tuple combinators
concurrency.combinators generalizations hashtables
help.stylesheet http.client io io.styles json.reader kernel
math.parser namespaces sequences strings urls.secure ;

IN: bitcoin-watcher

TUPLE: site name currency ;

TUPLE: bitcoin-url name url currency ;

CONSTANT: bitcoin-urls {
    { T{ site f "bitstamp" "$" } "https://www.bitstamp.net/api/ticker" }
    { T{ site f "btc100" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=btc100Ticker&suffix=0.16103304247371852" }
    { T{ site f "btcchina" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=btcchinaTicker&suffix=0.3849131213501096" }
    { T{ site f "btctrade" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=btctradeTicker&suffix=0.1531917753163725" }
    { T{ site f "chbtc" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=chbtcTicker&suffix=0.5108873315621167" }
    { T{ site f "futures796" "$" } "http://www.btc123.com/e/interfaces/tickers.php?type=796futuresTicker&suffix=0.38433733163401484" }
    { T{ site f "fxbtc" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=fxbtcTicker&suffix=0.19148686854168773" }
    { T{ site f "mtgox" "$" } "http://www.btc123.com/e/interfaces/tickers.php?type=MtGoxTicker&suffix=0.8636577818542719" }
    { T{ site f "okcoin" "¥" } "http://www.btc123.com/e/interfaces/tickers.php?type=okcoinTicker&suffix=0.7636065774131566" }
}

TUPLE: quote bid ask high low last volume ;

C: <quote> quote

<PRIVATE

: (bitcoin-quotes) ( -- json )
    bitcoin-urls [ http-get* "" like json> ] parallel-assoc-map ;

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

: bitcoin-quotes. ( -- )
    table-style get [
        bitcoin-quotes [
            [
                [ [ name>> ] [ currency>> ] bi ]
                [ [ last>> ] [ volume>> ] bi ] bi*
                [ number>string append ] [ number>string ] bi*
                [ [ write ] with-cell ] tri@
            ] with-row
        ] assoc-each
    ] tabular-output nl ;

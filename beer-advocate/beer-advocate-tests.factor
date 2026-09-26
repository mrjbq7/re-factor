USING: accessors beer-advocate combinators kernel present sequences tools.test
urls ;
IN: beer-advocate.tests

{ "https://www.beeradvocate.com/search/?q=pliny" } [
    "pliny" beer-search-url present
] unit-test

{ "ale & lager" } [
    "ale & lager" beer-search-url present >url "q" query-param
] unit-test

{ 0 } [
    "<ul><li><a href='/beer/profile/863/'>A brewery</a></li></ul>"
    parse-beer-search length
] unit-test

{ "Pliny The Elder" "Russian River" "California" f } [
    "<ul><li><a href='/beer/profile/863/7971/'>Pliny <b>The Elder</b></a><a href='/beer/profile/863/'>Russian River</a><span>| California</span></li></ul>"
    parse-beer-search first
    { [ name>> ] [ brewer>> ] [ location>> ] [ retired?>> ] } cleave
] unit-test

{ 1 "https://www.beeradvocate.com/beer/profile/863/7971/" "" "" t } [
    "<table><tr><td><ul><li><a href='https://www.beeradvocate.com/beer/profile/863/7971/'>Pliny</a><span>Retired</span></li></ul></td></tr></table>"
    parse-beer-search [ length ] [ first ] bi
    { [ url>> ] [ brewer>> ] [ location>> ] [ retired?>> ] } cleave
] unit-test

{ 0 } [ "<p>No results.</p>" parse-beer-search length ] unit-test

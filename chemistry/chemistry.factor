
USING: arrays fry kernel make math math.parser multiline
peg.ebnf sequences strings ;

IN: chemistry

<PRIVATE

EBNF: parse-symbol [=[

symbol = [A-Z] [a-z]? => [[ sift >string ]]

pair   = [0-9]* { symbol | "("~ pair+ ")"~ } [0-9]*

       => [[ first3 swapd [ [ 1 ] [ string>number ] if-empty ] bi@ * 2array ]]

bracket = "["~ pair "]"~

pairs  = (bracket | pair)+ => [[ ]]

]=]

: flatten-symbol, ( elt n -- )
    [ first2 ] [ * ] bi* over string?
    [ 2array , ] [ '[ _ flatten-symbol, ] each ] if ;

: flatten-symbol ( str -- seq )
    parse-symbol [ [ 1 flatten-symbol, ] each ] { } make ;

PRIVATE>

: symbol>string ( str -- str' )
    flatten-symbol [
        first2 dup 1 = [ drop ] [ number>string prepend ] if
    ] map " " join ;

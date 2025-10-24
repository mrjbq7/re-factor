
USING: arrays assocs fry kernel make math math.parser multiline
peg.ebnf sequences sorting strings ;

IN: chemistry

<PRIVATE

EBNF: split-formula [=[

symbol = [A-Z] [a-z]? => [[ sift >string ]]

number = [0-9]+ { "." [0-9]+ }? { { "e" | "E" } { "+" | "-" }? [0-9]+ }?

       => [[ first3 [ concat ] bi@ "" 3append-as string>number ]]

pair   = number? { symbol | "("~ pair+ ")"~ | "["~ pair+ "]"~ } number?

       => [[ first3 swapd [ 1 or ] bi@ * 2array ]]

pairs  = pair+

]=]

: flatten-formula ( elt n assoc -- )
    [ [ first2 ] [ * ] bi* ] dip pick string?
    [ swapd at+ ] [ '[ _ _ flatten-formula ] each ] if ;

PRIVATE>

: parse-formula ( str -- seq )
    split-formula H{ } clone [
        '[ 1 _ flatten-formula ] each
    ] keep ;

: formula>string ( str -- str' )
    parse-formula sort-keys [
        dup 1 number= [ drop ] [ number>string prepend ] if
    ] { } assoc>map " " join ;

USING: math.parser peg.ebnf sequences sequences.deep ;
IN: semantic-versioning.ebnf

EBNF: parse-semvar [=[

letter = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J"
       | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T"
       | "U" | "V" | "W" | "X" | "Y" | "Z" | "a" | "b" | "c" | "d"
       | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n"
       | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x"
       | "y" | "z"

positive-digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"

digit = "0" | positive-digit

digits = ( digit digits ) | digit

non-digit = letter | "-"

identifier-character = digit | non-digit

identifier-characters
    = ( identifier-character identifier-character )
    | identifier-character

numeric-identifier
    = ( positive-digit digits )
    | positive-digit
    | "0"

alphanumeric-identifier
    = ( identifier-character non-digit identifier-character )
    | ( identifier-character non-digit )
    | ( non-digit identifier-character )
    | non-digit
    => [[ flatten ]]

build-identifier = alphanumeric-identifier | digits

pre-release-identifier = alphanumeric-identifier | digits

dot-separated-build-identifiers
    = ( build-identifier "."~ dot-separated-build-identifiers )
    | build-identifier

build = dot-separated-build-identifiers => [[ ]]

dot-separated-pre-release-identifiers
    = ( pre-release-identifier "."~ dot-separated-pre-release-identifiers )
    | pre-release-identifier

pre-release = dot-separated-pre-release-identifiers => [[ ]]

patch = numeric-identifier => [[ flatten concat string>number ]]

minor = numeric-identifier => [[ flatten concat string>number ]]

major = numeric-identifier => [[ flatten concat string>number ]]

version-core = major "."~ minor "."~ patch

valid-semvar
    = ( version-core "-"~ pre-release "+"~ build )
    | ( version-core "-"~ pre-release )
    | ( version-core "+"~ build )
    | version-core

]=]

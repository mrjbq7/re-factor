USING: arrays byte-arrays formatting fry io.encodings.ascii
io.files kernel kernel.private math math.parser sequences
sequences.extras splitting ;

IN: k-nn

: slurp-file ( path -- {pixels,label} )
    ascii file-lines rest [
        "," split [ string>number ] B{ } map-as unclip 2array
    ] map ;

: distance ( x y -- z )
    { byte-array byte-array } declare 0 [ - sq + ] 2reduce ;

: classify ( training pixels -- label )
    '[ first _ distance ] infimum-by second ;

: validate ( training validation -- % )
    [ first2 [ classify ] [ = ] bi* ] with count* ;

: k-nn ( -- )
    "vocab:k-nn/trainingsample.csv" slurp-file
    "vocab:k-nn/validationsample.csv" slurp-file
    validate 100.0 * "Percentage correct: %f\n" printf ;

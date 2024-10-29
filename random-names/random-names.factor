! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs assocs.extras fry grouping io.encodings.utf8
io.files kernel make math memoize random sequences splitting ;

IN: random-names

MEMO: demon-names ( -- seq )
    "vocab:random-names/demon-names.txt" utf8 file-lines ;

MEMO: bom-names ( -- seq )
    "vocab:random-names/bom-names.txt" utf8 file-lines ;

MEMO: star-trek-races ( -- seq )
    "vocab:random-names/star-trek-races.txt" utf8 file-lines ;

MEMO: country-names ( -- seq )
    "vocab:random-names/country-names.txt" utf8 file-lines ;

<PRIVATE

: transitions ( string -- enum )
    { f } { } append-as 2 clump <enumerated> ;

: transition-table ( seq -- table )
    H{ } clone swap [ transitions assoc-merge! ] each ;

: next-char, ( prev index assoc -- next )
    at swap [ '[ drop _ = ] assoc-filter ] when*
    random [ first , ] [ second ] bi ;

: random-name ( table -- name )
    [
        f 0 [
            [ pick next-char, ] [ 1 + ] bi over
        ] loop 3drop
    ] "" make ;

PRIVATE>

: generate-name ( seq -- name )
    transition-table random-name ;

: generate-names ( n seq -- names )
    transition-table '[ _ random-name ] replicate ;

! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs fry grouping io.encodings.utf8 io.files kernel
make math memoize random sequences ;

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
    { f } { } append-as 2 clump <enum> ;

: (transition-table) ( string assoc -- )
    [ transitions ] dip '[ swap _ push-at ] assoc-each ;

: transition-table ( seq -- assoc )
    H{ } clone [ [ (transition-table) ] curry each ] keep ;

: next-char, ( prev index assoc -- next )
    at swap [ [ nip = ] curry assoc-filter ] when*
    random [ first , ] [ second ] bi ;

PRIVATE>

: generate-name ( seq -- name )
    transition-table [
        f 0 [
            [ pick next-char, ] [ 1 + ] bi over
        ] loop 3drop
    ] "" make ;

: generate-names ( n seq -- names )
    [ generate-name ] curry replicate ;

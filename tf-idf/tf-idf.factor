! Copyright (C) 2011 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators.short-circuit fry
io.encodings.utf8 io.files kernel math math.functions
math.statistics memoize sequences sets sorting splitting
unicode.case unicode.categories utils ;

IN: tf-idf

! TOKENIZE

: split-words ( string -- words )
    [ { [ Letter? ] [ digit? ] } 1|| not ] split-when harvest ;

MEMO: stopwords ( -- words )
    "vocab:tf-idf/stopwords.txt" utf8 file-lines fast-set ;

: tokenize ( string -- words )
    >lower split-words [ stopwords in? not ] filter ;

! INDEX

: tokenize-files ( paths -- assoc )
    [ dup utf8 file-contents tokenize ] H{ } map>assoc ;

: index1 ( path words -- path index )
    histogram [ pick swap 2array ] assoc-map ;

: index-all ( assoc -- index )
    [ index1 ] assoc-map values assoc-merge ;

TUPLE: db docs index ;

: <db> ( docs -- db )
    dup index-all db boa ;

! TF-IDF

: idf ( term db -- idf )
    [ nip docs>> ] [ index>> at ] 2bi
    [ assoc-size 1 + ] bi@ / log ;

: tf-idf ( term db -- scores )
    [ index>> at ] [ idf ] 2bi '[ _ * ] assoc-map ;

! SEARCH

: scores ( query db -- scores )
    [ >lower split-words ] dip '[ _ tf-idf ] map assoc-merge ;

: (normalize) ( path db -- value )
    [ docs>> at ] keep '[ _ idf 2 ^ ] map-sum sqrt ;

: normalize ( scores db -- scores' )
    '[ sum over _ (normalize) / ] assoc-map ;

: search ( query db -- scores )
    [ scores ] keep normalize sort-values reverse ;

! MISC

USE: io.directories
USE: io.pathnames

: load-db ( directory -- db )
    [ directory-files ] keep '[ _ prepend-path ] map
    tokenize-files <db> ;

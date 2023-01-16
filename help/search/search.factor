! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs formatting help help.markup help.topics io
kernel sequences strings tf-idf ;

IN: help.search

<PRIVATE

: load-article-db ( titles -- db )
    [
        dup article-content [ string? ] filter concat tokenize
    ] { } map>assoc <db> ;

PRIVATE>

: search-articles ( string -- results )
    all-articles load-article-db search ;

CONSTANT: max-results 20

: search. ( string -- )
    search-articles max-results index-or-length head [
        [ \ $link swap 2array ] [ "%.5f" sprintf ] bi*
    ] assoc-map $table nl ;

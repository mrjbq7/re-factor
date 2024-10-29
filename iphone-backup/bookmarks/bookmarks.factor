! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs db db.sqlite db.tuples db.types
io.directories io.files.info io.files.unique io.pathnames
iphone-backup kernel sequences sets sorting urls utils ;

IN: iphone-backup.bookmarks

CONSTANT: bookmarks-db "d1f062e2da26192a6625d968274bfda8d07821e4"

: last-bookmarks ( -- path )
    last-backup bookmarks-db append-path ;

: with-bookmarks-db ( quot -- )
    [ last-bookmarks ] dip with-copy-sqlite-db ; inline

TUPLE: bookmark id special-id parent type title url num-children
editable? deletable? hidden? hidden-ancestor-count order-index
external-uuid server-id sync-key sync-data deleted?
extra-attributes dav-generation ;

bookmark "bookmarks" {
    { "id" "id" INTEGER }
    { "special-id" "special_id" INTEGER }
    { "parent" "parent" INTEGER }
    { "type" "type" INTEGER }
    { "title" "title" TEXT }
    { "url" "url" TEXT }
    { "num-children" "num_children" INTEGER }
    { "editable?" "editable" INTEGER }
    { "deletable?" "deletable" INTEGER }
    { "hidden?" "hidden" INTEGER }
    { "hidden-ancestor-count" "hidden_ancestor_count" INTEGER }
    { "order-index" "order_index" INTEGER }
    { "external-uuid" "external_uuid" TEXT }
    { "server-id" "server_id" TEXT }
    { "sync-key" "sync_key" TEXT }
    { "sync-data" "sync_data" BLOB }
    { "deleted?" "deleted" INTEGER }
    { "extra-attributes" "extra_attributes" BLOB }
    { "dav-generation" "dav_generation" INTEGER }
} define-persistent

: count-bookmarks ( -- n )
    T{ bookmark { num-children 0 } } count-tuples ;

: all-bookmarks ( -- seq )
    T{ bookmark { num-children 0 } } select-tuples ;

: all-urls ( -- seq )
    all-bookmarks [ [ url>> ] [ title>> ] bi ] { } map>assoc ;

: all-domains ( -- seq )
    all-bookmarks [ url>> >url host>> ] map members ;

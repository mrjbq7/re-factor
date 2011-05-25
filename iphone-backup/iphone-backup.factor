! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors db db.sqlite db.tuples db.types io.directories
io.files.info io.files.unique io.pathnames kernel sequences
sorting utils ;

IN: iphone-backup

: last-modified ( path -- path' )
    [
        [ file-info modified>> ] sort-with last
    ] with-directory-files ;

: last-backup ( -- path )
    home "Library/Application Support/MobileSync/Backup"
    append-path dup last-modified append-path ;

: <copy-sqlite-db> ( path -- sqlite-db )
    temporary-file [ copy-file ] [ <sqlite-db> ] bi ;

: with-copy-sqlite-db ( path quot -- )
    [ <copy-sqlite-db> ] dip with-db ; inline


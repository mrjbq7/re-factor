! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors db db.sqlite db.tuples db.types io.directories
io.files.info io.files.unique io.pathnames kernel sequences
sorting utils ;

IN: iphone-backup

! CONSTANT: text-messages "3d0d7e5fb2ce288813306e4d4636395e047a3d28"
! CONSTANT: address-book "31bb7ba8914766d4ba40d6dfb6113c8b614be442"
! CONSTANT: locations "4096c9ec676f2847dc283405900e284a7c815836"
! CONSTANT: web-cookies "462db712aa8d833ff164035c1244726c477891bd"
! CONSTANT: phone-db "790885a13b24eabcce43db750d654a228fc2395b"
! CONSTANT: voicemails "992df473bbb9e132f4b3b6e4d33f72171e97bc7a"
! CONSTANT: photos "bedec6d42efe57123676bfa31e98ab68b713195f"

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


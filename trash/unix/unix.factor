! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors calendar classes.struct environment formatting
io io.directories io.encodings.utf8 io.files io.files.info
io.files.info.unix io.files.types io.pathnames kernel math
math.parser sequences system trash unix.stat ;

FROM: unix.ffi => getuid ;

IN: trash.unix

! Implements the FreeDesktop.org Trash Specification 0.7

<PRIVATE

: (lstat) ( path -- stat )
    \ stat <struct> [
        lstat dup 0 = [ drop ] [ number>string throw ] if
    ] keep ;

: top-directory? ( path -- ? )
    [ (lstat) ] [ ".." append-path (lstat) ] bi
    [ [ st_dev>> ] bi@ = not ] [ [ st_ino>> ] bi@ = ] 2bi or ;

: top-directory ( path -- path' )
    [ dup top-directory? not ] [ ".." append-path ] while ;


: make-user-directory ( path -- )
    [ make-directories ] [ OCT: 700 set-file-permissions ] bi ;


: (directory?) ( path -- )
    file-info directory?
    [ "topdir should be a directory" throw ] unless ;

: (sticky-bit?) ( path -- )
    sticky?
    [ "topdir should have sticky bit" throw ] unless ;

: (not-symlink?) ( path -- )
    link-info type>> +symbolic-link+ =
    [ "topdir can't be a symbolic link" throw ] when ;

: trash-path? ( path -- )
    [ (directory?) ] [ (sticky-bit?) ] [ (not-symlink?) ] tri ;


: trash-home ( -- path )
    "XDG_DATA_HOME" os-env [ ] [
        home ".local/share" append-path
    ] if* "Trash" append-path dup trash-path? ;

: trash-1 ( root -- path )
    ".Trash" append-path dup trash-path?
    getuid number>string append-path
    [ make-user-directory ] keep ;

: trash-2 ( root -- path )
    getuid ".Trash-%d" sprintf append-path
    [ make-user-directory ] keep ;


: trash-path ( path -- path' )
    top-directory dup trash-home top-directory = [
        trash-home nip
    ] [
        dup ".Trash" append-path exists?
        [ trash-1 ] [ trash-2 ] if
    ] if ;


: (safe-file-name) ( path counter -- path' )
    [
        [ parent-directory ]
        [ file-stem ]
        [ file-extension dup [ "." prepend ] when ] tri
    ] dip swap "%s%s %s%s" sprintf ;

: safe-file-name ( path -- path' )
    dup 0 [ over exists? ] [
        1 +
        [ parent-directory to-directory ] dip
        [ (safe-file-name) ] keep
    ] while drop nip ;

PRIVATE>

M: unix send-to-trash ( path -- )
    dup trash-path [
        "files" append-path [ make-user-directory ] keep
        to-directory safe-file-name
    ] [
        "info" append-path [ make-user-directory ] keep
        to-directory ".trashinfo" append
        [ over ] dip utf8 [
            "[Trash Info]" write nl
            "Path=" write write nl
            "DeletionDate=" write
            now "%Y-%m-%dT%H:%M:%S" strftime write nl
        ] with-file-writer
    ] bi move-file ;



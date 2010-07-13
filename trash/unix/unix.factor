! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: environment trash unix.stat ;

IN: trash.unix

! Implements the FreeDesktop.org Trash Specification 0.7

<PRIVATE

: (lstat) ( path -- stat )
    \ stat <struct> [
        lstat dup 0 = [ drop ] [ number>string throw ] if
    ] keep ;

: mount? ( path -- ? )
    [ (lstat) ] [ ".." append-path (lstat) ] bi
    [ [ st_dev>> ] bi@ = not ] [ [ st_ino>> ] bi@ = ] 2bi or ;

: mount-point ( path -- path' )
    [ dup mount? not ] [ ".." append-path ] while ;


: make-user-directory ( path -- )
    [ make-directories ]
    [ OCT: 700 set-file-permissions ] bi ;


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
    mount-point dup trash-home mount-point = [
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
        "files" append-path make-user-directory
        to-directory safe-file-name
    ] keep

    "info" append-path make-user-directory
    to-directory ".trashinfo" append
    [ over ] utf8 [
        "[Trash Info]" write nl
        "Path=" write write nl
        "DeletionDate=" write
        now "%Y-%m-%dT%H:%M:%S" strftime write nl
    ] with-file-writer ;

    move-file ;



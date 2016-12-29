! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs checksums checksums.md5 command-line
formatting fry io.directories.search io.files.types io.pathnames
kernel math math.parser namespaces sequences ;

IN: dupe

: collect-files ( path -- assoc )
    t H{ } clone [
        '[
            dup type>> +regular-file+ = [
                name>> dup file-name _ push-at
            ] [ drop ] if
        ] each-directory-entry
    ] keep ;

: duplicate-files ( path -- dupes )
    collect-files [ nip length 1 > ] assoc-filter! ;

: md5-file ( path -- string )
    md5 checksum-file bytes>hex-string ;

: print-md5 ( name paths -- )
    [ "%s:\n" printf ] [
        [ dup md5-file "  %s\n    %s\n" printf ] each
    ] bi* ;

: arg? ( name args -- args' ? )
    2dup member? [ remove t ] [ nip f ] if ;

: parse-args ( -- verbose? root )
    "--verbose" command-line get arg? swap first ;

: run-dupe ( -- )
    parse-args duplicate-files swap
    [ dup [ print-md5 ] assoc-each ] when
    assoc-size "Total duped files found: %d\n" printf ;

MAIN: run-dupe

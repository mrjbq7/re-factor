! Copyright (C) 2010 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays combinators db db.private db.queries
db.tuples db.tuples.private db.types destructors kernel
math.parser mysql.errors mysql.ffi mysql.lib namespaces nmake
random sequences ;

IN: mysql

TUPLE: mysql-db host username password database port ;

: <mysql-db> ( -- db )
    f f f f 0 mysql-db boa ;




<PRIVATE

TUPLE: mysql-db-connection < db-connection ;

: <mysql-db-connection> ( handle -- db-connection )
    mysql-db-connection new-db-connection
        swap >>handle ;

PRIVATE>


M: mysql-db db-open ( db -- db-connection )
    {
        [ host>> ]
        [ username>> ]
        [ password>> ]
        [ database>> ]
        [ port>> ]
    } cleave mysql-connect <mysql-db-connection> ;

M: mysql-db-connection db-close ( handle -- )
    mysql_close ;


TUPLE: mysql-statement < statement ;

M: mysql-db-connection <simple-statement> ( str in out -- stmt )
    mysql-statement new-statement ;

M: mysql-db-connection <prepared-statement> ( str in out -- stmt )
    <simple-statement> dup prepare-statement ;



! db.tuples

M: mysql-db-connection create-sql-statement ( class -- seq )
    [
        dupd
        "create table " 0% 0%
        "(" 0% [ ", " 0% ] [
            "`" 0% dup column-name>> 0% "`" 0%
            " " 0%
            dup type>> lookup-create-type 0%
            modifiers 0%
        ] interleave

        ", " 0%
        find-primary-key
        "primary key(" 0%
        [ "," 0% ] [ "`" 0% column-name>> 0% "`" 0% ] interleave
        "));" 0%
    ] query-make 1array ;

M: mysql-db-connection drop-sql-statement ( class -- seq )
    [ nip "drop table " 0% 0% ";" 0% ] query-make ;

M: mysql-db-connection <insert-db-assigned-statement> ( class -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        remove-db-assigned-id
        dup [ ", " 0% ] [ "`" 0% column-name>> 0% "`" 0% ] interleave
        ") values(" 0%
        [ ", " 0% ] [
            dup type>> +random-id+ = [
                [ slot-name>> ]
                [
                    column-name>> ":" prepend dup 0%
                    random-id-generator
                ] [ type>> ] tri <generator-bind> 1,
            ] [
                bind%
            ] if
        ] interleave
        ");" 0%
    ] query-make ;

M: mysql-db-connection <insert-user-assigned-statement> ( class -- statement )
    <insert-db-assigned-statement> ;

M: mysql-db-connection insert-tuple-set-key ( tuple statement -- )
    "not implemented" throw ; ! query-modify-tuple ;

M: mysql-db-connection <select-by-slots-statement>
    [
        "select " 0% [ dupd filter-ignores ] dip over empty?
        [ all-slots-ignored ] when over
        [ ", " 0% ] [ "`" 0% dup column-name>> 0% "`" 0% 2, ] interleave
        " from " 0% 0% where-clause
    ] query-make ;




! FIXME: the problem with insert-tuple is that it expects
! to use statements with in-params>> ?
! "insert into TEST1(ID, A, B, C) values(:ID, :A, :B, :C);"

! db.types

! FIXME: from db.postgresql
: bind-name% ( -- ) 36 0, sql-counter [ inc ] [ get 0# ] bi ;

M: mysql-db-connection bind% ( spec -- )
    bind-name% 1, ;

M: mysql-db-connection bind# ( spec object -- )
    [ bind-name% f swap type>> ] dip <literal-bind> 1, ;

ERROR: no-compound-found string object ;
M: mysql-db-connection compound ( string object -- string' )
    ! FIXME: verify these
    over {
        { "default" [ first number>string " " glue ] }
        { "varchar" [ first number>string "(" ")" surround append ] }
        { "references" [ >reference-string ] }
        [ drop no-compound-found ]
    } case ;

M: mysql-db-connection persistent-table ( -- hashtable )
    ! FIXME: verify these
    H{
        { +db-assigned-id+ { "integer" "serial" f } }
        { +user-assigned-id+ { f f f } }
        { +random-id+ { "bigint" "bigint" f } }

        { +foreign-id+ { f f "references" } }

        { +on-update+ { f f "on update" } }
        { +on-delete+ { f f "on delete" } }
        { +restrict+ { f f "restrict" } }
        { +cascade+ { f f "cascade" } }
        { +set-null+ { f f "set null" } }
        { +set-default+ { f f "set default" } }

        { TEXT { "text" "text" f } }
        { VARCHAR { "varchar" "varchar" f } }
        { INTEGER { "integer" "integer" f } }
        { BIG-INTEGER { "bigint" "bigint" f } }
        { UNSIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { SIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { DOUBLE { "double" "double" f } }
        { DATE { "date" "date" f } }
        { TIME { "time" "time" f } }
        { DATETIME { "datetime" "datetime" f } }
        { TIMESTAMP { "timestamp" "timestamp" f } }
        { BLOB { "blob" "blob" f } }
        { FACTOR-BLOB { "blob" "blob" f } }
        { URL { "varchar" "varchar" f } }

        { +autoincrement+ { f f "autoincrement" } }
        { +unique+ { f f "unique" } }
        { +default+ { f f "default" } }
        { +null+ { f f "null" } }
        { +not-null+ { f f "not null" } }
        { system-random-generator { f f f } }
        { secure-random-generator { f f f } }
        { random-generator { f f f } }
    } ;







TUPLE: mysql-result-set < result-set ;

M: mysql-result-set #rows ( result-set -- n )
    handle>> [ mysql-#rows ] [ 0 ] if* ;

M: mysql-result-set #columns ( result-set -- n )
    handle>> [ mysql-#columns ] [ 0 ] if* ;

M: mysql-result-set row-column ( result-set n -- obj )
    [ handle>> ] dip mysql-column ;

M: mysql-result-set row-column-typed ( result-set n -- obj )
    [ handle>> ] dip mysql-column-typed ;

M: mysql-result-set advance-row ( result-set -- )
    handle>> [ mysql-next drop ] when* ;

M: mysql-result-set more-rows? ( result-set -- ? )
    handle>> [ current_row>> ] [ f ] if* ;

M: mysql-result-set dispose ( result-set -- )
    [ handle>> [ mysql_free_result ] when* ]
    [
        0 >>n
        0 >>max
        f >>handle drop
    ] bi ;




! db

M: mysql-statement bind-statement* ( statement -- )
    drop "not implemented" throw ;

M: mysql-statement low-level-bind ( statement -- )
    drop "not implemented" throw ;


GENERIC: postgresql-bind-conversion
    ( tuple object -- low-level-binding )

M: generator-bind postgresql-bind-conversion
    dup generator-singleton>> eval-generator
    [ swap slot-name>> rot set-slot-named ]
    [ <low-level-binding> ] bi ;

M: literal-bind postgresql-bind-conversion
    nip value>> <low-level-binding> ;

M: sql-spec postgresql-bind-conversion
    slot-name>> swap get-slot-named <low-level-binding> ;

M: mysql-statement bind-tuple ( tuple statement -- )
    [ nip ] [
        in-params>> [ postgresql-bind-conversion ] with map
    ] 2bi
    >>bind-params drop ;


USE: io.encodings.string
USE: io.encodings.utf8

: mysql-handle ( statement -- handle )
    dup handle>> [
        db-connection get handle>> >>handle
    ] unless handle>> ;

: mysql-prepare ( stmt sql -- stmt )
    utf8 encode dup length
    dupd mysql_stmt_prepare
    dupd mysql-stmt-check-result ;

: mysql-maybe-prepare ( statement -- statement )
    dup handle>> [
        db-connection get handle>> mysql_stmt_init
        over sql>> mysql-prepare >>handle
    ] unless ;

: do-mysql-bound-statement ( statement -- res )
    mysql-maybe-prepare ;


: do-mysql-statement ( statement -- res )
    [ mysql-handle ] [ sql>> ] bi mysql-query ;

M: mysql-statement query-results ( statement -- result-set )
    dup do-mysql-statement mysql-result-set new-result-set
    dup advance-row ;

M: mysql-statement prepare-statement ( statement -- )
    drop "not implemented" throw ;

M: mysql-db-connection parse-db-error
    ! FIXME: check n 0 > ?
    string>> parse-mysql-sql-error ;

M: mysql-statement dispose ( statement -- )
    f >>handle drop ;






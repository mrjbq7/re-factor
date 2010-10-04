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

M: mysql-db-connection db-close ( handle -- ) mysql_close ;


TUPLE: mysql-statement < statement ;

M: mysql-db-connection <simple-statement> ( str in out -- obj )
    mysql-statement new-statement ;

M: mysql-db-connection <prepared-statement> ( str in out -- obj )
    <simple-statement> dup prepare-statement ;



USE: io
USE: prettyprint




! db.tuples

M: mysql-db-connection create-sql-statement ( class -- seq )
    [
        dupd
        "create table " 0% 0%
        "(" 0% [ ", " 0% ] [
            dup column-name>> 0%
            " " 0%
            dup type>> lookup-create-type 0%
            modifiers 0%
        ] interleave

        ", " 0%
        find-primary-key
        "primary key(" 0%
        [ "," 0% ] [ column-name>> 0% ] interleave
        "));" 0%
    ] query-make 1array ;

M: mysql-db-connection drop-sql-statement ( class -- seq )
    [ nip "drop table " 0% 0% ";" 0% ] query-make ;

M: mysql-db-connection <insert-db-assigned-statement> ( tuple -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        remove-db-assigned-id
        dup [ ", " 0% ] [ column-name>> 0% ] interleave
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

M: mysql-db-connection <insert-user-assigned-statement> ( tuple -- statement )
    <insert-db-assigned-statement> ;

M: mysql-db-connection insert-tuple-set-key ( tuple statement -- )
    query-modify-tuple ;


FROM: db.postgresql => bind-name% ;

! FIXME: the problem with insert-tuple is that it expects
! to use statements with in-params>> ?
! "insert into TEST1(ID, A, B, C) values(:ID, :A, :B, :C);"

! db.types

M: mysql-db-connection bind% ( spec -- )
    bind-name% 1, ;

M: mysql-db-connection bind# ( spec object -- )
    [ bind-name% f swap type>> ] dip <literal-bind> 1, ;

ERROR: no-compound-found string object ;
M: mysql-db-connection compound ( string object -- string' )
    ! FIXME:
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
    handle>> mysql-#rows ;

M: mysql-result-set #columns ( result-set -- n )
    handle>> mysql-#columns ;

M: mysql-result-set row-column ( result-set n -- obj )
    [ handle>> ] dip mysql-column ;

M: mysql-result-set row-column-typed ( result-set n -- obj )
    [ handle>> ] dip mysql-column-typed ;

M: mysql-result-set advance-row ( result-set -- )
    handle>> mysql-next drop ;

M: mysql-result-set more-rows? ( result-set -- ? )
    handle>> current_row>> ;

M: mysql-result-set dispose ( result-set -- )
    [ handle>> mysql_free_result ]
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

FROM: db.postgresql => postgresql-bind-conversion ;

M: mysql-statement bind-tuple ( tuple statement -- )
    [ nip ] [
        in-params>> [ postgresql-bind-conversion ] with map
    ] 2bi
    >>bind-params drop ;


! FIXME: move do-mysql-statement to mysql.lib?

USE: io.encodings.string
USE: io.encodings.utf8

: mysql-prepare ( stmt sql -- handle )
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
    dup handle>> [ db-connection get handle>> >>handle ] unless
    [ handle>> ] [ sql>> dup . ] bi mysql-query ;


M: mysql-statement query-results ( statement -- result-set )
    dup do-mysql-statement
    mysql-result-set new-result-set dup advance-row
    "query-results" write nl ;

M: mysql-statement prepare-statement ( statement -- )
    drop "not implemented" throw ;

M: mysql-db-connection parse-db-error
    dup . string>> parse-mysql-sql-error ;

M: mysql-statement dispose ( statement -- )
    f >>handle drop ;







: trac-db ( -- db )
    <mysql-db>
        "localhost" >>host
        "trac" >>username
        "trac" >>password
        "trac" >>database ;

: with-trac-db ( quot -- )
    trac-db swap with-db ; inline





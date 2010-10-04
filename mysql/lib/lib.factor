! Copyright (C) 2010 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.strings
classes.struct combinators db.errors fry generalizations
io.encodings.utf8 layouts kernel make math math.parser mysql.ffi
sequences sequences.deep ;

IN: mysql.lib

ERROR: mysql-error < db-error n string ;
! ERROR: mysql-sql-error < sql-error n string ;

: mysql-connect ( host user passwd db port -- mysql )
    [ f mysql_init ] 5 ndip f 0 mysql_real_connect ;

: mysql-check-result ( mysql n -- )
    dup 0 = [ 2drop ] [
        swap mysql_error mysql-error
    ] if ;

: mysql-stmt-check-result ( stmt n -- )
    dup 0 = [ 2drop ] [
        swap mysql_stmt_error mysql-error
    ] if ;

: mysql-#rows ( result -- n ) mysql_num_rows ;

: mysql-#columns ( result -- n ) mysql_num_fields ;

: mysql-next ( result -- ? ) mysql_fetch_row ;

: mysql-column ( result n -- value )
    swap [ cell * ] [ current_row>> ] bi* <displaced-alien>
    *void* utf8 alien>string ;

: mysql-row ( result -- seq )
    [ current_row>> ] [ mysql-#columns ] bi [
        [ *void* utf8 alien>string ]
        [ cell swap <displaced-alien> ] bi swap
    ] replicate nip ;

: mysql-query ( mysql query -- result )
    dupd mysql_query dupd mysql-check-result
    mysql_store_result ;



CONSTANT: MIN_CHAR -255
CONSTANT: MAX_CHAR 256

CONSTANT: MIN_SHORT -65535
CONSTANT: MAX_SHORT 65536

CONSTANT: MIN_INT -4294967295
CONSTANT: MAX_INT 4294967296

CONSTANT: MIN_LONG -18446744073709551615
CONSTANT: MAX_LONG 18446744073709551616

: fixnum>c-ptr ( n -- c-ptr )
    dup dup 0 < [ abs 1 + ] when {
        { [ dup MAX_CHAR  <= ] [ drop <char> ] }
        { [ dup MAX_SHORT <= ] [ drop <short> ] }
        { [ dup MAX_INT   <= ] [ drop <int> ] }
        { [ dup MAX_LONG  <= ] [ drop <longlong> ] }
        [ "too big" throw ]
    } cond ;




! : mysql-stmt-query ( stmt -- result )
!     dup mysql_stmt_execute dupd mysql-stmt-check-result
!     mysql_stmt_store_result ;


: mysql-column-typed ( result n -- value )
    [ mysql-column ] [ mysql_fetch_field_direct ] 2bi type>> {
        { MYSQL_TYPE_DECIMAL  [ string>number ] }
        { MYSQL_TYPE_SHORT    [ string>number ] }
        { MYSQL_TYPE_LONG     [ string>number ] }
        { MYSQL_TYPE_FLOAT    [ string>number ] }
        { MYSQL_TYPE_DOUBLE   [ string>number ] }
        { MYSQL_TYPE_LONGLONG [ string>number ] }
        { MYSQL_TYPE_INT24    [ string>number ] }
        [ drop ]
    } case ;












: cols ( result n -- cols )
    [ dup mysql_fetch_field name>> ] replicate nip ;

: row ( result n -- row/f )
    swap mysql_fetch_row [
        swap [
            [ *void* utf8 alien>string ]
            [ cell swap <displaced-alien> ] bi swap
        ] replicate nip
    ] [ drop f ] if* ;

: rows ( result n -- rows )
    [ '[ _ _ row dup ] [ , ] while drop ] { } make ;



: create-db ( mysql db -- )
    dupd mysql_create_db mysql-check-result ;

: drop-db ( mysql db -- )
    dupd mysql_drop_db mysql-check-result ;

: select-db ( mysql db -- )
    dupd mysql_select_db mysql-check-result ;

: list-dbs ( mysql -- seq )
    f mysql_list_dbs dup mysql_num_fields rows flatten ;

: list-tables ( mysql -- seq )
    f mysql_list_tables dup mysql_num_fields rows flatten ;

: list-processes ( mysql -- seq )
    mysql_list_processes dup mysql_num_fields rows ;


: query-db ( mysql sql -- cols rows )
    mysql-query [
        dup mysql_num_fields [ cols ] [ rows ] 2bi
    ] [ mysql_free_result ] bi ;


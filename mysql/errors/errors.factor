! Copyright (C) 2010 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: db.errors kernel peg.ebnf quoting strings ;

IN: mysql.errors

EBNF: parse-mysql-sql-error [=[

TableError =
    "Table '" (!("'").)+:table "' already exists"
        => [[ table >string unquote <sql-table-exists> ]]
    | "Table '" (!("'").)+:table "' doesn't exist"
        => [[ table >string unquote <sql-table-missing> ]]
    | "Unknown table '" (!("'").)+:table "'"
        => [[ table >string unquote <sql-table-missing> ]]

SyntaxError =
    "You have an error in your SQL syntax":error
        => [[ error >string <sql-syntax-error> ]]

UnknownError = .* => [[ >string <sql-unknown-error> ]]

MysqlSqlError = (TableError | SyntaxError | UnknownError)

]=]



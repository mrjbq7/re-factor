! Copyright (C) 2010 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: db.errors kernel peg.ebnf quoting strings ;

IN: mysql.errors

EBNF: parse-mysql-sql-error

TableError =
    "Table " (!(" already exists").)+:table " already exists"
        => [[ table >string unquote <sql-table-exists> ]]
    | "Table " (!(" doesn't exist").)+:table " doesn't exist"
        => [[ table >string unquote <sql-table-missing> ]]

SyntaxError =
    "You have an error in your SQL syntax":error
        => [[ error >string <sql-syntax-error> ]]

UnknownError = .* => [[ >string <sql-unknown-error> ]]

MysqlSqlError = (TableError | SyntaxError | UnknownError)

;EBNF



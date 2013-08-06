! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs combinators.short-circuit fry
grouping kernel make regexp sequences ;

IN: verbal-expressions

TUPLE: verbal-expression prefix source suffix modifiers ;

: <verbal-expressions> ( -- verbexp )
    "" "" "" "" verbal-expression boa ; inline

ALIAS: <verbexp> <verbal-expressions>

: >regexp ( verbexp -- regexp )
    [ [ prefix>> ] [ source>> ] [ suffix>> ] tri 3append ]
    [ modifiers>> ] bi <optioned-regexp> ; inline

: build-regexp ( ... quot: ( ... verbexp -- ... verbexp ) -- ... regexp )
    '[ <verbexp> @ >regexp ] call ; inline

<PRIVATE

: add ( verbexp str -- verbexp )
    '[ _ append ] change-source ;

: add-modifier ( verbexp ch -- verbexp )
    '[ _ suffix ] change-modifiers ;

: remove-modifier ( verbexp ch -- verbexp )
    '[ _ swap remove ] change-modifiers ;

: re-escape ( str -- str' )
    [
        [
            dup { [ Letter? ] [ digit? ] } 1||
            [ CHAR: \ , ] unless ,
        ] each
    ] "" make ;

PRIVATE>

: anything ( verbexp -- verbexp )
    "(?:.*)" add ;

: anything-but ( verbexp value -- verbexp )
    re-escape "(?:[^" "]*)" surround add ;

: something ( verbexp -- verbexp )
    "(?:.+)" add ;

: something-but ( verbexp value -- verbexp )
    re-escape "(?:[^" "]+)" surround add ;

: end-of-line ( verbexp -- verbexp )
    [ "$" append ] change-suffix ;

: maybe ( verbexp value -- verbexp )
    re-escape "(?:" ")?" surround add ;

: start-of-line ( verbexp -- verbexp )
    [ "^" append ] change-prefix ;

: then ( verbexp value -- verbexp )
    re-escape "(?:" ")" surround add ;

: any-of ( verbexp value -- verbexp )
    re-escape "(?:[" "])" surround add ;

: line-break ( verbexp -- verbexp )
    "(?:(?:\\n)|(?:\\r\\n))" add ;

ALIAS: br line-break

: range ( verbexp alist -- verbexp )
    [ [ re-escape ] bi@ "-" glue ] { } assoc>map concat
    "([" "])" surround add ;

: tab ( verbexp -- verbexp )
    "\\t" add ;

: word ( verbexp -- verbexp )
    "\\w+" add ;

: spaces ( verbexp -- verbexp )
    "\\s+" add ;

: -or- ( verbexp -- verbexp )
    [ "(" append ] change-prefix
    [ ")|(" append ] change-source
    [ ")" prepend ] change-suffix ;

: case-insensitive ( verbexp -- verbexp )
    CHAR: i add-modifier ;

: case-sensitive ( verbexp -- verbexp )
    CHAR: i remove-modifier ;

: multiline ( verbexp -- verbexp )
    CHAR: m add-modifier ;

: singleline ( verbexp -- verbexp )
    CHAR: m remove-modifier ;

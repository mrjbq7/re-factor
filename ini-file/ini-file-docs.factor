! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs hashtables help.syntax help.markup io strings ;

IN: ini-file

HELP: read-ini
{ $values { "assoc" assoc } }
{ $description
    "Reads and parses an INI file from the " { $link input-stream }
    " and returns the result as a nested " { $link hashtable }
    "."
} ;

HELP: parse-ini
{ $values { "str" string } { "assoc" assoc } }
{ $description
    "Parses the specified " { $link string } " as an INI file"
    " and returns the result as a nested " { $link hashtable }
    "."
} ;


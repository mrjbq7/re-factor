! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup math strings time ;

IN: time

HELP: seconds-since-1900
{ $values { "seconds" integer } }
{ $description
    "Returns the number of seconds between January 1, 1900 and the "
    "current time."
} ;

HELP: time-server
{ $description
    "Starts a TIME server on 127.0.0.1:3700."
} ;

HELP: time-client
{ $values { "seconds" integer } }
{ $description
    "Retrieves the current time from a TIME server running on "
    "127.0.0.1:3700."
} ;


#!/Users/jbenedik/Projects/factor/factor
USING: fry io kernel sequences ;

IN: birthday

: sing ( name -- )
   4 iota swap '[
        "Happy Birthday " write
        2 = "dear " _ append "to You" ? print
    ] each ;

: main ( -- )
    "Who do you want to sing to? " write flush
    readln sing ;

MAIN: main


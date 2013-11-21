#!/Users/jbenedik/Projects/factor/factor
USING: fry io kernel sequences text-to-speech ;

IN: birthday

: sing ( name -- )
   4 iota swap '[
        2 = "dear " _ append "to You" ?
        "Happy Birthday " prepend [ print ] [ speak ] bi
    ] each ;

: birthday ( -- )
    "Who do you want to sing to? " write flush readln sing ;

MAIN: birthday

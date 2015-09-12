USING: ascii kernel math sequences ;

IN: pig-latin

: vowel? ( ch -- ? ) ch>lower "aeiou" member? ;

: pig-latin ( str -- str' )
    dup [ vowel? ] find drop [
        "way" append
    ] [
        cut swap "ay" 3append
    ] if-zero ;

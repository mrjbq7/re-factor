! Copyright (C) 2023 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii kernel make math sbufs sequences ;

IN: vigenere

CONSTANT: LETTERS "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

<PRIVATE

:: viginere ( msg key encrypt? -- str )
    msg >upper :> MSG
    key >upper :> KEY

    [
        0 MSG [| ch |
            ch LETTERS index [| i |
                [ 1 + KEY length mod i ] keep
                KEY nth LETTERS index
                encrypt? [ + ] [ - ] if
                LETTERS length [ + ] [ mod ] bi
                LETTERS nth ,
            ] when*
        ] each drop
    ] "" make ;

PRIVATE>

: >vigenere ( msg key -- encrypted ) t viginere ;

: vigenere> ( msg key -- decrypted ) f viginere ;

<PRIVATE

:: autokey ( msg key encrypt? -- str )
    msg >upper :> MSG
    key >upper >sbuf :> KEY

    [
        0 MSG [| ch |
            ch LETTERS index [| i |
                [ 1 + i ] keep
                KEY encrypt? [ ch suffix! ] when nth
                LETTERS index
                encrypt? [ + ] [ - ] if
                LETTERS length [ + ] [ mod ] bi
                LETTERS nth
                encrypt? [ KEY over suffix! drop ] unless ,
            ] when*
        ] each drop
    ] "" make ;

PRIVATE>

: >autokey ( msg key -- encrypted ) t autokey ;

: autokey> ( msg key -- decrypted ) f autokey ;



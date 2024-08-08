! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs command-loop formatting io kernel math
math.functions math.parser namespaces sequences splitting ;

IN: cash-register

CONSTANT: COINS {
    { 50000 "$500" }
    { 10000 "$100" }
    { 5000 "$50" }
    { 2000 "$20" }
    { 1000 "$10" }
    { 500 "$5" }
    { 200 "$2" }
    { 100 "$1" }
    { 25 "quarters" }
    { 10 "dimes" }
    { 5 "nickels" }
    { 1 "pennies" }
}

: make-change ( n -- assoc )
    COINS [ [ /mod swap ] dip ] assoc-map swap 0 assert= ;

: $. ( n -- )
    100 /f "$%.2f\n" printf ;

: change. ( n -- )
    "CHANGE: " write dup $.
    make-change [
        '[ _ "%d of %s\n" printf ] unless-zero
    ] assoc-each ;

INITIALIZED-SYMBOL: owed [ 0 ]

INITIALIZED-SYMBOL: paid [ 0 ]

: balance. ( -- )
    "OWED: " write owed get-global $.
    "PAID: " write paid get-global $. ;

: charge ( n -- )
    "CHARGE: " write dup $.
    owed [ + ] change-global balance. ;

: pay ( n -- )
    "PAY: " write dup $.
    paid [ + ] change-global balance.
    paid get-global owed get-global - dup 0 >=
    [ change. 0 owed set-global 0 paid set-global ] [ drop ] if ;

: cancel ( -- )
    "CANCEL" print
    0 owed set-global
    paid [ change. 0 ] change-global ;

: parse-$ ( args -- n )
    "$" ?head drop string>number 100 * round >integer ;

CONSTANT: COMMANDS {
    T{ command
        { name "balance" }
        { quot [ drop balance. ] }
        { help "Display current balance." }
        { abbrevs { "b" } } }
    T{ command
        { name "charge" }
        { quot [ parse-$ charge ] }
        { help "Charge an item." }
        { abbrevs { "c" } } }
    T{ command
        { name "pay" }
        { quot [ parse-$ pay ] }
        { help "Pay with money." }
        { abbrevs { "p" } } }
    T{ command
        { name "cancel" }
        { quot [ drop cancel ] }
        { help "Cancel transaction." }
        { abbrevs { "x" } } }
}

: cash-register-main ( -- )
    "Welcome to the Cash Register!" "$>"
    command-loop new-command-loop
    COMMANDS [ over add-command ] each
    run-command-loop ;

MAIN: cash-register-main


USING: enigma kernel tools.test ;

IN: enigma.tests

[ "" ] [ "" 4 <enigma> encode ] unit-test

[ "hello, world" ] [
    "hello, world" 4 <enigma> [ encode ] keep reset-cogs encode
] unit-test

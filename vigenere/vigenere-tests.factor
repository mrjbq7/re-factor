USING: tools.test vigenere ;

{ "AKIJRAODRJQQSGAISQMUODMPHUMRS" } [
    "This is Harshil Darji from Dharmaj." "HDarji" >vigenere
] unit-test

{ "THISISHARSHILDARJIFROMDHARMAJ" } [
    "Akij ra Odrjqqs Gaisq muod Mphumrs." "HDarji" vigenere>
] unit-test

{ "QNXEPVYTWTWP" } [ "attackatdawn" "QUEENLY" >autokey ] unit-test
{ "ATTACKATDAWN" } [ "qnxepvytwtwp" "QUEENLY" autokey> ] unit-test

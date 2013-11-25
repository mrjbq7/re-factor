
USING: tools.test ;

IN: n-numbers

{ f } [ "N0" n-number? ] unit-test
{ t } [ "N1" n-number? ] unit-test
{ f } [ "N1I" n-number? ] unit-test
{ t } [ "N123AZ" n-number? ] unit-test
{ t } [ "N1234Z" n-number? ] unit-test
{ t } [ "N12345" n-number? ] unit-test

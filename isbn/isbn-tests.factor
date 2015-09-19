USING: tools.test ;
IN: isbn

{ t } [ "0-306-40615-2" valid-isbn? ] unit-test
{ t } [ "978-0-306-40615-7" valid-isbn? ] unit-test

{ 2 } [ "0-306-40615-?" calc-isbn-10-check ] unit-test
{ 7 } [ "978-0-306-40615-?" calc-isbn-13-check ] unit-test


USING: kernel tools.test ;

IN: rock-paper-scissors

{ t } [ \ scissors \ paper beats? ] unit-test
{ f } [ \ scissors \ paper swap beats? ] unit-test
{ t } [ \ rock \ scissors beats? ] unit-test
{ f } [ \ rock \ scissors swap beats? ] unit-test
{ t } [ \ paper \ rock beats? ] unit-test
{ f } [ \ paper \ rock swap beats? ] unit-test
{ f } [ \ rock \ rock beats? ] unit-test
{ f } [ \ paper \ paper beats? ] unit-test
{ f } [ \ scissors \ scissors beats? ] unit-test

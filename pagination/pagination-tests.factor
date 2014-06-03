USING: tools.test ;
IN: pagination

{ { 1 2 3 99 100 } } [ 1 100 pages-to-show ] unit-test
{ { 1 2 21 22 23 24 25 27 28 } } [ 23 28 pages-to-show ] unit-test
{ { 1 2 3 } } [ 1 3 pages-to-show ] unit-test

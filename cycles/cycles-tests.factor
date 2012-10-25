
USING: math.ranges tools.test ;
IN: cycles

{
    { 22 11 34 17 52 26 13 40 20 10 5 16 8 4 2 1 }
} [ 22 cycles ] unit-test

{ 1  } [ 1 num-cycles ] unit-test
{ 2  } [ 2 num-cycles ] unit-test
{ 6  } [ 5 num-cycles ] unit-test
{ 16 } [ 22 num-cycles ] unit-test

{ 20  } [ 1 10 [a,b] max-cycles ] unit-test
{ 125 } [ 100 200 [a,b] max-cycles ] unit-test
{ 89  } [ 201 210 [a,b] max-cycles ] unit-test
{ 174 } [ 900 1000 [a,b] max-cycles ] unit-test

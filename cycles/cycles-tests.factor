
USING: cycles ranges tools.test ;

{
    { 22 11 34 17 52 26 13 40 20 10 5 16 8 4 2 1 }
} [ 22 cycles ] unit-test

{ 1  } [ 1 cycle-length ] unit-test
{ 2  } [ 2 cycle-length ] unit-test
{ 6  } [ 5 cycle-length ] unit-test
{ 16 } [ 22 cycle-length ] unit-test

{ 20  } [ 1 10 [a..b] max-cycle-length ] unit-test
{ 125 } [ 100 200 [a..b] max-cycle-length ] unit-test
{ 89  } [ 201 210 [a..b] max-cycle-length ] unit-test
{ 174 } [ 900 1000 [a..b] max-cycle-length ] unit-test

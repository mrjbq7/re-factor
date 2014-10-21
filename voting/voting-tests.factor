USING: tools.test ;
IN: voting

{ 3 } [
    {
        { 1 2 3 } { 1 3 2 } { 2 3 1 }
        { 3 1 2 } { 3 2 1 } { 2 3 1 }
    } instant-runoff
] unit-test

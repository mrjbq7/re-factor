
USING: sequences square tools.test ;

[ t ] [
    {
        { { 0 0 } { 0 1 } { 1 1 } { 1 0 } }   ! standard square
        { { 0 0 } { 2 1 } { 3 -1 } { 1 -2 } } ! non-axis-aligned square
        { { 0 0 } { 1 1 } { 0 1 } { 1 0 } }   ! different order
        { { 0 0 } { 0 4 } { 2 2 } { -2 2 } }  ! rotated square
    } [ square? ] all?
] unit-test

[ f ] [
    {
        { { 0 0 } { 0 2 } { 3 2 } { 3 0 } }   ! rectangle
        { { 0 0 } { 3 4 } { 8 4 } { 5 0 } }   ! rhombus
        { { 0 0 } { 0 0 } { 1 1 } { 0 0 } }   ! only 2 distinct points
        { { 0 0 } { 0 0 } { 1 0 } { 0 1 } }   ! only 3 distinct points
    } [ square? ] any?
] unit-test


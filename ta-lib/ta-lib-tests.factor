USING: accessors kernel sequences specialized-arrays ta-lib tools.test ;

SPECIALIZED-ARRAY: double

{ t } [
    10 <iota> 3 SUM
    double-array{ 0/0. 0/0. 3.0 6.0 9.0 12.0 15.0 18.0 21.0 24.0 }
    [ underlying>> ] bi@ =
] unit-test

USING: math reasoning tools.test ;

{ 15 } [
    [ "x" 0 * 1 + 3 * 12 + ] quot>expr simplify-value
] unit-test

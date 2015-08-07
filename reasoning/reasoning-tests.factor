USING: math reasoning tools.test ;

{
    T{ Add f
        T{ Mul f
            T{ Add f
                T{ Mul f
                    T{ Var { s "x" } }
                    T{ Const { n 0 } } }
                T{ Const { n 1 } } }
            T{ Const { n 3 } } }
        T{ Const { n 12 } } }
} [ [ "x" 0 * 1 + 3 * 12 + ] >expr ] unit-test

{ 15 } [
    [ "x" 0 * 1 + 3 * 12 + ] >expr simplify-value
] unit-test

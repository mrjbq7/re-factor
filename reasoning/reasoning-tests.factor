USING: reasoning tools.test ;

{ 15 } [
    T{ Add f
        T{ Mul f
            T{ Add f
                T{ Const f 1 }
                T{ Mul f
                    T{ Const f 0 }
                    T{ Var f "x" } } }
            T{ Const f 3 } }
        T{ Const f 12 } }
    simplify-value
] unit-test


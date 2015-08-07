USING: combinators fry kernel literals match math prettyprint
quotations sequences strings ;
FROM: fry => _ ;
IN: reasoning

TUPLE: Var s ;
TUPLE: Const n ;
TUPLE: Add x y ;
TUPLE: Mul x y ;

MATCH-VARS: ?x ?y ;

: simplify1 ( expr -- expr' )
    {
        { T{ Add f T{ Const f 0 } ?x } [ ?x ] }
        { T{ Add f ?x T{ Const f 0 } } [ ?x ] }
        { T{ Mul f ?x T{ Const f 1 } } [ ?x ] }
        { T{ Mul f T{ Const f 1 } ?x } [ ?x ] }
        { T{ Mul f ?x T{ Const f 0 } } [ T{ Const f 0 } ] }
        { T{ Mul f T{ Const f 0 } ?x } [ T{ Const f 0 } ] }
        { T{ Add f T{ Const f ?x } T{ Const f ?y } } [ ?x ?y + Const boa ] }
        { T{ Mul f T{ Const f ?x } T{ Const f ?y } } [ ?x ?y * Const boa ] }
        [ ]
    } match-cond ;

: simplify ( expr -- expr' )
    {
        { T{ Add f ?x ?y } [ ?x ?y [ simplify ] bi@ Add boa ] }
        { T{ Mul f ?x ?y } [ ?x ?y [ simplify ] bi@ Mul boa ] }
        [ ]
    } match-cond simplify1 ;

: simplify-value ( expr -- str )
    simplify {
        { T{ Const f ?x } [ ?x ] }
        [ drop "The expression could not be simplified to a Constant." ]
    } match-cond ;

: >expr ( quot -- expr )
    [
        {
            { [ dup string? ] [ '[ _ Var boa ] ] }
            { [ dup integer? ] [ '[ _ Const boa ] ] }
            { [ dup \ + = ] [ drop [ Add boa ] ] }
            { [ dup \ * = ] [ drop [ Mul boa ] ] }
        } cond
    ] map concat call( -- expr ) ;

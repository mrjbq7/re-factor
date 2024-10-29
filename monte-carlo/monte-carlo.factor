
USING: fry kernel math math.functions math.statistics namespaces
random random.private sequences ;

IN: monte-carlo

! I’m going to propose a contract: I will flip a coin ten times,
! and if I get three heads in a row I will give you $1. How much
! will you pay me to enter into that contract?

: 10-flips ( -- seq )
    10 [ random-unit 0.5 > ] replicate ;

: payoff ( -- n )
    { t t t } 10-flips subseq? 1.0 0.0 ? ;

: contract-value ( flips -- value-estimate )
    [ payoff ] replicate mean ;

! Estimate pi

: random-point* ( obj -- x y )
    [ random-unit* ] [ random-unit* ] bi ;

: random-point ( -- x y )
    random-generator get random-point* ;

: inside-circle? ( x y -- ? )
    [ sq ] bi@ + sqrt 1.0 <= ;

: estimate-pi ( points -- pi-estimate )
    0 swap [
        random-generator get
        '[
            _ random-point* inside-circle? [ 1 + ] when
        ] times
    ] keep /f 4 * ;

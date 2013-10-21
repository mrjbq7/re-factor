
USING: kernel math.factorials sequences tools.test ;

IN: fast-factorial

{ t } [
    1,000 factorials [ fast-factorial = ] map-index [ ] all?
] unit-test

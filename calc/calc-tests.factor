! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: calc math math.functions quotations tools.test ;

IN: calc.tests

[ "2" calc ] must-infer

[  2 ] [  "2" calc ] unit-test
[ -2 ] [ "-2" calc ] unit-test

[  2.0 ] [  "2." calc ] unit-test
[ -2.0 ] [ "-2." calc ] unit-test

[  2.3 ] [  "2.3" calc ] unit-test
[ -2.3 ] [ "-2.3" calc ] unit-test

5 2 + 1quotation [ "5+2" calc ] unit-test
5 2 - 1quotation [ "5-2" calc ] unit-test
5 2 * 1quotation [ "5*2" calc ] unit-test
5 2 / 1quotation [ "5/2" calc ] unit-test
5 2 mod 1quotation [ "5%2" calc ] unit-test
5 2 ^ 1quotation [ "5^2" calc ] unit-test
5 2 shift 1quotation [ "5>>2" calc ] unit-test
5 -2 shift 1quotation [ "5<<2" calc ] unit-test

3 abs 1quotation [ "abs(3)" calc ] unit-test
3 ceiling 1quotation [ "ceil(3)" calc ] unit-test
3 cos 1quotation [ "cos(3)" calc ] unit-test
3 cosh 1quotation [ "cosh(3)" calc ] unit-test
3 cot 1quotation [ "cot(3)" calc ] unit-test
3 coth 1quotation [ "coth(3)" calc ] unit-test
3 e^ 1quotation [ "exp(3)" calc ] unit-test
3 >float 1quotation [ "float(3)" calc ] unit-test
3 floor 1quotation [ "floor(3)" calc ] unit-test
3 >fixnum 1quotation [ "int(3)" calc ] unit-test
3 log 1quotation [ "log(3)" calc ] unit-test
3 log10 1quotation [ "log10(3)" calc ] unit-test
3 round 1quotation [ "round(3)" calc ] unit-test
3 sin 1quotation [ "sin(3)" calc ] unit-test
3 sinh 1quotation [ "sinh(3)" calc ] unit-test
3 sqrt 1quotation [ "sqrt(3)" calc ] unit-test
3 tan 1quotation [ "tan(3)" calc ] unit-test
3 tanh 1quotation [ "tanh(3)" calc ] unit-test

2 3 sin + 5 cos + 1quotation [ "2+sin(3)+cos(5)" calc ] unit-test



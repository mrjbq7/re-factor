! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: math.ranges pseudo-crypt sequences tools.test ;

IN: pseudo-crypt

[
    {
        "cJio3" "EdRc6" "qxAQ9" "TGtEC" "5ac2F" "huKqI" "KE3eL"
        "wXmSO" "YrVGR" "BBE4U"
    }
] [ 10 [1,b] [ 5 udihash ] map ] unit-test


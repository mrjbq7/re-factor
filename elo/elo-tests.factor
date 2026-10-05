USING: arrays elo kernel math math.functions sequences tools.test ;
IN: elo.tests

! Expected score depends on the rating difference, from A's perspective.
{ 0.5 } [ 1500 1500 elo-expected ] unit-test
{ t } [ 1800 1400 elo-expected 10/11 1e-12 ~ ] unit-test
{ t } [ 1400 1800 elo-expected 1/11 1e-12 ~ ] unit-test
{ t } [ 1600 1400 elo-expected 0.759746926647958 1e-12 ~ ] unit-test
{ t } [ 1600 1400 elo-expected 2600 2400 elo-expected = ] unit-test
{ t } [ 1600 1400 elo-expected 1400 1600 elo-expected + 1 1e-12 ~ ] unit-test

! Equal ratings: win, draw, and loss. Both outputs use the old ratings.
{ 1516.0 1484.0 } [ 1500 1500 1 32 elo ] unit-test
{ 1500.0 1500.0 } [ 1500 1500 0.5 32 elo ] unit-test
{ 1484.0 1516.0 } [ 1500 1500 0 32 elo ] unit-test

! A predicted win is worth less than an upset.
{ t t } [
    1800 1400 1 32 elo
    [ 1802.909090909091 1e-9 ~ ]
    [ 1397.090909090909 1e-9 ~ ] bi*
] unit-test
{ t t } [
    1400 1800 1 32 elo
    [ 1429.090909090909 1e-9 ~ ]
    [ 1770.909090909091 1e-9 ~ ] bi*
] unit-test

! Drawing a stronger opponent gains points.
{ t t } [
    1400 1800 0.5 32 elo
    [ 1413.090909090909 1e-9 ~ ]
    [ 1786.909090909091 1e-9 ~ ] bi*
] unit-test

! K controls the size of the change, including zero for no adjustment.
{ 1508.0 1492.0 } [ 1500 1500 1 16 elo ] unit-test
{ 1400.0 1800.0 } [ 1400 1800 1 0 elo ] unit-test

! Same K for both players: preserve the total and player-order symmetry.
{ t } [
    { 0 0.5 1 } [ 1632 1487 rot 32 elo + 3119 1e-9 ~ ] all?
] unit-test
{ t } [
    1632 1487 1 32 elo 2array
    1487 1632 0 32 elo swap 2array
    [ 1e-9 ~ ] 2all?
] unit-test

! Successive games can use the previous pair directly, without rounding.
{ t t } [
    1500 1500 1 32 elo 0.5 32 elo
    [ 1514.5304984710245 1e-9 ~ ]
    [ 1485.4695015289755 1e-9 ~ ] bi*
] unit-test


USING: bowling tools.test ;

IN: bowling.tests

[ 0 ] [ "--" score-frame ] unit-test
[ 4 ] [ "4-" score-frame ] unit-test
[ 9 ] [ "-9" score-frame ] unit-test
[ 10 ] [ "X" score-frame ] unit-test
[ 10 ] [ "4/" score-frame ] unit-test

[ 0 ] [ "---------------------" score-game ] unit-test
[ 80 ] [ "-8-7714215X6172183-" score-game ] unit-test
[ 83 ] [ "12X4--3-69/-98/8-8-" score-game ] unit-test
[ 144 ] [ "XXX6-3/819-44X6-" score-game ] unit-test
[ 266 ] [ "XXXXXXXXX81-" score-game ] unit-test
[ 271 ] [ "XXXXXXXXX9/2" score-game ] unit-test
[ 279 ] [ "XXXXXXXXXX33" score-game ] unit-test
[ 295 ] [ "XXXXXXXXXXX5" score-game ] unit-test
[ 300 ] [ "XXXXXXXXXXXX" score-game ] unit-test
[ 100 ] [ "-/-/-/-/-/-/-/-/-/-/-" score-game ] unit-test
[ 190 ] [ "9/9/9/9/9/9/9/9/9/9/9" score-game ] unit-test

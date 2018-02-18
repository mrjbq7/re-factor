USING: math math.constants math.functions sequences tools.test ;
IN: spark

{ "█▁█▁" } [ { 1 0 1 0 } spark ] unit-test
{ "█▁█▁▄" } [ { 1 0 1 0 0.5 } spark ] unit-test
{ "█▄█▄▁" } [ { 1 0 1 0 -1 } spark ] unit-test

{ "▁▁▃▂█" } [ { 1 5 22 13 53 } spark ] unit-test
{ "▄▆▂█▁" } [ { 9 13 5 17 1 } spark ] unit-test

{ "▁▂▃▄▂█" } [ "0,30,55,80,33,150" spark ] unit-test
{ "▁▂▃▄▂█" } [ { 0 30 55 80 33 150 } spark ] unit-test
{ "▃▄▅▆▄█" } [ { 0 30 55 80 33 150 } -100 spark-min ] unit-test
{ "▁▅██▅█" } [ { 0 30 55 80 33 150 } 50 spark-max ] unit-test
{ "▁▁▄█▁█" } [ { 0 30 55 80 33 150 } 30 80 spark-range ] unit-test

{ "▄▆█▆▄▂▁▂▄" } [ 9 <iota> [ pi 4 / * sin ] map spark ] unit-test
{ "█▆▄▂▁▂▄▆█" } [ 9 <iota> [ pi 4 / * cos ] map spark ] unit-test

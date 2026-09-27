USING: math math.constants math.functions sequences tools.test ;
IN: sparkline

{ "█▁█▁" } [ { 1 0 1 0 } sparkline ] unit-test
{ "█▁█▁▄" } [ { 1 0 1 0 0.5 } sparkline ] unit-test
{ "█▄█▄▁" } [ { 1 0 1 0 -1 } sparkline ] unit-test

{ "▁▁▃▂█" } [ { 1 5 22 13 53 } sparkline ] unit-test
{ "▄▆▂█▁" } [ { 9 13 5 17 1 } sparkline ] unit-test

{ "▁▂▃▄▂█" } [ "0,30,55,80,33,150" sparkline ] unit-test
{ "▁▂▃▄▂█" } [ { 0 30 55 80 33 150 } sparkline ] unit-test
{ "▃▄▅▆▄█" } [ { 0 30 55 80 33 150 } -100 sparkline-min ] unit-test
{ "▁▅██▅█" } [ { 0 30 55 80 33 150 } 50 sparkline-max ] unit-test
{ "▁▁▄█▁█" } [ { 0 30 55 80 33 150 } 30 80 sparkline-range ] unit-test

{ "▄▆█▆▄▂▁▂▄" } [ 9 <iota> [ pi 4 / * sin ] map sparkline ] unit-test
{ "█▆▄▂▁▂▄▆█" } [ 9 <iota> [ pi 4 / * cos ] map sparkline ] unit-test

{ { "▁▂▃" "▆▇█" } } [
    { { 0 1 2 } { 5 6 7 } } sparklines
] unit-test

{ { "█▄" "▁▄█" } } [
    { { 7 0 } { -7 0 7 } } sparklines
] unit-test

{ { "▁▁" "▁" } } [
    { { 5 5 } { 5 } } sparklines
] unit-test

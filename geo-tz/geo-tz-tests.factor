USING: tools.test ;
IN: geo-tz

{ "America/Los_Angeles" } [ 37.7833 -122.4167 lookup-zone ] unit-test
{ "Australia/Sydney" } [ -33.8885 151.1908 lookup-zone ] unit-test
{ f } [ 0 0 lookup-zone ] unit-test

{ "Asia/Phnom_Penh" } [ 9200 2410 lookup-pixel ] unit-test
{ "Asia/Phnom_Penh" } [ 9047 2488 lookup-pixel ] unit-test

! one-bit leaf tile
{ "Asia/Krasnoyarsk" } [ 9290 530 lookup-pixel ] unit-test
{ "Asia/Yakutsk" } [ 9290 531 lookup-pixel ] unit-test

! four-bit tile
{ "America/Indiana/Vincennes" } [ 2985 1654 lookup-pixel ] unit-test
{ "America/Indiana/Marengo" } [ 2986 1654 lookup-pixel ] unit-test
{ "America/Indiana/Tell_City" } [ 2986 1655 lookup-pixel ] unit-test

! Empty tile
{ f } [ 4000 2000 lookup-pixel ] unit-test

! Big 1-color tile in ocean with island
{ "Atlantic/Bermuda" } [ 3687 1845 lookup-pixel ] unit-test
! Same, but off Oregon coast
{ "America/Los_Angeles" } [ 1747 1486 lookup-pixel ] unit-test

! Little solid tile
{ "America/Belize" } [ 2924 2316 lookup-pixel ] unit-test

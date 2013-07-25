
USING: tools.test ;

IN: metar

{ "freezing fog" } [ "FZFG" parse-abbreviations ] unit-test
{ { "FZ" "FG" } } [ "FZFG" split-abbreviations ] unit-test

{ { "RA" "B" "15" "E" "25" } } [ "RAB15E25" split-abbreviations ] unit-test

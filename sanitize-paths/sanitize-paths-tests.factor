USING: combinators kernel sequences strings tools.test ;

IN: sanitize-paths

{ "abcdef" } [ "abcdef" sanitize-path ] unit-test

! test special characters
{ t } [
    "<>|/\\*?:" [
        1string {
            [ sanitize-path "file" = ]
            [ "a" prepend sanitize-path "a" = ]
            [ "a" append sanitize-path "a" = ]
            [ "a" "a" surround sanitize-path "aa" = ]
        } cleave and and and
    ] all?
] unit-test

! test unicode
{ "笊, ざる.pdf" } [ "笊, ざる.pdf" sanitize-path ] unit-test
{ "whatēverwëirduserînput" } [
    "  what\\ēver//wëird:user:înput:" sanitize-path ] unit-test

! test windows reserved named
{ t } [
    { "CON" "lpt1" "com4" " aux" " LpT\x122" }
    [ sanitize-path "file" = ] all?
] unit-test
{ "COM10" } [ "COM10" sanitize-path ] unit-test

! test blanks
{ "file" } [ "<" sanitize-path ] unit-test

! test dots
{ "file.pdf" } [ ".pdf" sanitize-path ] unit-test
{ "file.pdf" } [ "<.pdf" sanitize-path ] unit-test
{ "file..pdf" } [ "..pdf" sanitize-path ] unit-test

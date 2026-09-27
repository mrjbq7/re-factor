USING: io.directories io.encodings.utf8 io.files io.pathnames
locals math.parser namespaces ui.gadgets.worlds unix.signals
accessors bigbuts combinators io.launcher kernel sequences tools.test ui.gadgets ;
IN: bigbuts.tests

{ { { "demo" "echo hello:world" } { "pwd" "pwd" } } } [
    "#!/usr/bin/env bigbuts\n # comment\n\ndemo: echo hello:world\npwd\n" parse-commands
] unit-test
{ { "echo" "echo hello" } } [ "  echo hello  " parse-command ] unit-test
{ { "x" "printf '# hi'" } } [ "x: printf '# hi'" parse-command ] unit-test
[ " # empty\n" parse-commands ] [ empty-bigbuts-config? ] must-fail-with
[ ": echo bad" parse-commands ] [ invalid-bigbuts-command? ] must-fail-with
[ "bad: " parse-commands ] [ invalid-bigbuts-command? ] must-fail-with
{ "config" "logs with spaces" t } [
    { "-g" "-l" "logs with spaces" "config" } parse-options
    [ file>> ] [ log-directory>> ] [ no-geometry?>> ] tri
] unit-test
[ { "-l" } parse-options ] [ invalid-bigbuts-option? ] must-fail-with
[ { "--unknown" } parse-options ] [ invalid-bigbuts-option? ] must-fail-with
[ { "one" "two" } parse-options ] [ invalid-bigbuts-option? ] must-fail-with
{ { "/bin/sh" "-c" "printf '%s' \"$HOME\"" } } [
    "printf '%s' \"$HOME\"" f command-argv
] unit-test
{ "a b'$(false)" "echo hi" } [
    "echo hi" "a b'$(false)" command-argv [ 4 swap nth ] [ last ] bi
] unit-test
{ 7 } [ "exit 7" f launch-command wait-for-process ] unit-test

{ t } [
    "a: echo a\nb: echo b" parse-commands f <bigbuts-state>
    <bigbuts-track> dup children>> clone swap
    dup rotate-buttons dup rotate-buttons dup rotate-buttons dup rotate-buttons
    children>> =
] unit-test

:: check-logs ( -- status stdout stderr )
    "printf 'out'; printf 'err' >&2; exit 3" current-directory get launch-command :> child
    child handle>> number>string :> pid
    child wait-for-process
    pid ".stdout" append utf8 file-contents
    pid ".stderr" append utf8 file-contents ;

{ 3 "out" "err" } [ [ check-logs ] with-test-directory ] unit-test

:: check-signal ( kill? -- signal-number )
    "exec sleep 30" f launch-command :> child
    { } f <bigbuts-state> kill? >>interrupted? :> state
    child state children>> push
    state interrupt-children
    child wait-for-process n>> ;

{ 2 } [ f check-signal ] unit-test
{ 9 } [ t check-signal ] unit-test

:: geometry-roundtrip ( -- ? )
    "a: true" parse-commands f <bigbuts-state>
    "geometry" absolute-path >>cache-file :> state
    <world-attributes> bigbuts-world >>world-class
    state <bigbuts-track> >>gadgets <world> state >>state
    { 24 42 } >>window-loc { 600 160 } >>dim :> window
    window children>> first rotate-buttons
    window save-geometry
    window { 0 0 } >>window-loc drop
    window children>> first 0 >>rotation drop
    window restore-geometry
    window window-loc>> { 24 42 } =
    window pref-dim>> { 600 160 } = and
    window children>> first rotation>> 1 = and ;

{ t } [ [ geometry-roundtrip ] with-test-directory ] unit-test

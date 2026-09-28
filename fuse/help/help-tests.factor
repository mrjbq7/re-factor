USING: accessors assocs byte-arrays continuations fuse fuse.help
io.encodings.string io.encodings.utf8 kernel libc math namespaces
sequences tools.test unix vocabs words ;
IN: fuse.help.tests

{ "%2F" "%25" "%2E" "%2E%2E" } [
    "/" help-filename "%" help-filename
    "." help-filename ".." help-filename
] unit-test

{ "math" "hello-world" } [
    "math" help-filename "hello-world" help-filename
] unit-test

SYMBOL: test-help-fs
{ "kernel" "math" } <help-fs-for> test-help-fs set

{ t } [ "/" test-help-fs get fs-getattr directory?>> ] unit-test
{ { "kernel" "math" } } [ "/" test-help-fs get fs-readdir ] unit-test
{ t } [ "/kernel" test-help-fs get fs-getattr directory?>> ] unit-test
{ t } [ "/kernel" test-help-fs get fs-readdir "dup" swap member? ] unit-test
{ t } [ "/math" test-help-fs get fs-readdir "%2F" swap member? ] unit-test
{ f } [ "/math/%2F" test-help-fs get fs-getattr directory?>> ] unit-test

{ t } [
    "/kernel/dup" 100000 0 test-help-fs get fs-read utf8 decode
    "Word description" swap subseq?
] unit-test

{ t } [
    "/kernel/dup" test-help-fs get fs-getattr size>>
    "/kernel/dup" 100000 0 test-help-fs get fs-read length =
] unit-test

{ t } [
    "/kernel/dup" 7 3 test-help-fs get fs-read
    "/kernel/dup" 100000 0 test-help-fs get fs-read 3 10 rot subseq =
] unit-test

{ B{ } } [ "/kernel/dup" 100 1000000 test-help-fs get fs-read ] unit-test
{ B{ } } [ "/kernel/dup" 0 0 test-help-fs get fs-read ] unit-test

[ "/missing" test-help-fs get fs-getattr ]
[ dup fuse-error? [ errno>> ENOENT = ] [ drop f ] if ] must-fail-with
[ "/kernel/missing" test-help-fs get fs-getattr ]
[ dup fuse-error? [ errno>> ENOENT = ] [ drop f ] if ] must-fail-with
[ "/kernel/dup" test-help-fs get fs-readdir ]
[ dup fuse-error? [ errno>> ENOTDIR = ] [ drop f ] if ] must-fail-with
[ "/kernel" 10 0 test-help-fs get fs-read ]
[ dup fuse-error? [ errno>> EISDIR = ] [ drop f ] if ] must-fail-with
[ "/kernel/dup" 10 -1 test-help-fs get fs-read ]
[ dup fuse-error? [ errno>> EINVAL = ] [ drop f ] if ] must-fail-with

! Exercise error containment at the C callback boundary without mounting.
{ t } [ 2 "/missing" f 0 0 test-help-fs get fuse-dispatch ENOENT neg = ] unit-test
{ t } [ 2 "/kernel" f 0 0 test-help-fs get fuse-dispatch EISDIR neg = ] unit-test
{ 0 } [ 2 "/kernel/dup" f 0 0 test-help-fs get fuse-dispatch ] unit-test
{ t } [ 99 "/" f 0 0 test-help-fs get fuse-dispatch ENOSYS neg = ] unit-test

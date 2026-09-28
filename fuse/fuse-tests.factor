USING: continuations accessors byte-arrays fuse io.encodings.string
io.encodings.utf8 kernel libc math tools.test ;
IN: fuse.tests

{ B{ 2 3 } } [ B{ 1 2 3 4 } 2 1 fuse-slice ] unit-test
{ B{ 4 } } [ B{ 1 2 3 4 } 10 3 fuse-slice ] unit-test
{ B{ } } [ B{ 1 2 3 4 } 10 4 fuse-slice ] unit-test
{ B{ } } [ B{ } 10 0 fuse-slice ] unit-test
{ B{ 195 } } [ "é" utf8 encode 1 0 fuse-slice ] unit-test
{ B{ 169 } } [ "é" utf8 encode 1 1 fuse-slice ] unit-test
[ B{ } 1 -1 fuse-slice ] [ fuse-error? ] must-fail-with

TUPLE: broken-fs < fuse-fs ;
M: broken-fs fs-getattr 2drop "unexpected failure" throw ;
{ t } [ 2 "/" f 0 0 broken-fs new fuse-dispatch EIO neg = ] unit-test

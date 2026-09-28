USING: environment vocabs.loader ;
<< "FACTOR_FUSE_ROOT" os-env add-vocab-root >>
USING: accessors fuse.help kernel namespaces prettyprint sequences
system tools.test ;
"fuse" test
test-failures get [ error>> . ] each
test-failures get empty? [ 0 ] [ 1 ] if exit

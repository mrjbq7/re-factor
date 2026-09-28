USING: environment vocabs.loader ;
<< "FACTOR_FUSE_ROOT" os-env add-vocab-root >>
USING: fuse fuse.help io kernel math namespaces ;

! The test library replaces libfuse's main loop with native assertions.
! Repeating catches stale callbacks and leaked mount state.
2 [
    { "kernel" "math" } <help-fs-for> "/unused-test-mountpoint" mount-fuse
    active-fuse-fs get-global f assert=
] times
"Native bridge callback tests passed." print

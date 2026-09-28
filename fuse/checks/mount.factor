USING: environment vocabs.loader ;
<< "FACTOR_FUSE_ROOT" os-env add-vocab-root >>
USING: command-line fuse fuse.help namespaces sequences ;
{ "kernel" "math" } <help-fs-for> command-line get first mount-fuse

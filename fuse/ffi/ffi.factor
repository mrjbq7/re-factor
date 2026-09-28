! Native layouts are handled by a bridge compiled against libfuse's headers.
USING: alien alien.c-types alien.libraries alien.syntax environment io.files
io.pathnames kernel system ;
IN: fuse.ffi

<< "factor-fuse" "FACTOR_FUSE_LIBRARY" os-env [
    os macos?
    [ "vocab:fuse/libfactor-fuse.dylib" ]
    [ "vocab:fuse/libfactor-fuse.so" ] if
    absolute-path
] unless* cdecl add-library >>

LIBRARY: factor-fuse

CALLBACK: int factor_fuse_dispatch ( int operation, c-string path,
    void* buffer, size_t size, int64_t offset )

FUNCTION: int factor_fuse_main ( c-string mountpoint, factor_fuse_dispatch dispatch )
FUNCTION: void factor_fuse_stat ( void* buffer, int directory, int64_t size )
FUNCTION: int factor_fuse_add_entry ( void* buffer, c-string name, int64_t next )

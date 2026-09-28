USING: accessors alien byte-arrays combinators continuations
fuse.ffi kernel libc locals math math.order namespaces sequences unix ;
IN: fuse

! Implement these three words to serve a read-only filesystem.
TUPLE: fuse-fs ;
TUPLE: fuse-entry directory? size ;
C: <fuse-entry> fuse-entry

GENERIC: fs-getattr ( path fs -- entry )
GENERIC: fs-readdir ( path fs -- names )
GENERIC: fs-read ( path size offset fs -- bytes )

ERROR: fuse-error errno ;
ERROR: fuse-mount-error status ;

: fuse-fail ( errno -- * ) fuse-error ;

M: fuse-fs fs-getattr 2drop ENOENT fuse-fail ;
M: fuse-fs fs-readdir 2drop ENOTDIR fuse-fail ;
M: fuse-fs fs-read 4drop ENOSYS fuse-fail ;

! Offsets and lengths are byte counts, including for UTF-8 text.
:: fuse-slice ( bytes size offset -- bytes' )
    offset 0 < size 0 < or [ EINVAL fuse-fail ] when
    offset bytes length min :> start
    start size + bytes length min :> end
    start end bytes subseq ;

:: fuse-getattr ( path buffer fs -- result )
    path fs fs-getattr :> entry
    buffer entry directory?>> [ 1 ] [ 0 ] if entry size>>
    factor_fuse_stat 0 ;

:: fuse-readdir ( path buffer offset fs -- result )
    offset 0 < [ EINVAL fuse-fail ] when
    { "." ".." } path fs fs-readdir append :> names
    offset :> index!
    f :> full?!
    [ index names length < full? not and ] [
        buffer index names nth index 1 + factor_fuse_add_entry
        0 = not full?!
        index 1 + index!
    ] while 0 ;

:: fuse-open ( path fs -- result )
    path fs fs-getattr directory?>> [ EISDIR fuse-fail ] when 0 ;

:: fuse-read ( path buffer size offset fs -- result )
    path size offset fs fs-read :> bytes
    bytes length size > [ EIO fuse-fail ] when
    bytes byte-array? [ EIO fuse-fail ] unless
    buffer bytes bytes length memcpy
    bytes length ;

:: fuse-dispatch ( operation path buffer size offset fs -- result )
    [
        operation {
            { 0 [ path buffer fs fuse-getattr ] }
            { 1 [ path buffer offset fs fuse-readdir ] }
            { 2 [ path fs fuse-open ] }
            { 3 [ path buffer size offset fs fuse-read ] }
            [ drop ENOSYS neg ]
        } case
    ] [ dup fuse-error? [ errno>> ] [ drop EIO ] if neg ] recover ;

! Callbacks start with a fresh namestack, so the active filesystem must be
! rooted globally. One foreground mount per VM; always clear it on exit.
SYMBOL: active-fuse-fs
ERROR: fuse-already-mounted ;

:: mount-fuse ( fs mountpoint -- )
    active-fuse-fs get-global [ fuse-already-mounted ] when
    fs active-fuse-fs set-global
    [
        [ active-fuse-fs get-global fuse-dispatch ] factor_fuse_dispatch
        [| callback |
            mountpoint callback factor_fuse_main
            dup 0 = [ drop ] [ fuse-mount-error ] if
        ] with-callback
    ] [ f active-fuse-fs set-global ] finally ;

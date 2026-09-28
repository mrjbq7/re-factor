USING: accessors assocs combinators fuse help io.encodings.string
io.encodings.utf8 io.streams.string kernel libc locals namespaces
sequences sorting splitting strings unix urls.encoding vocabs
vocabs.loader words ;
IN: fuse.help

! The index is frozen at construction; rendered UTF-8 help is cached on demand.
TUPLE: help-fs < fuse-fs vocabularies rendered ;

: help-filename ( name -- filename )
    url-encode-full {
        { "." [ "%2E" ] }
        { ".." [ "%2E%2E" ] }
        { "" [ "%00" ] }
        [ ]
    } case ;

: word-help-bytes ( word -- bytes )
    [ print-topic ] with-string-writer utf8 encode ;

:: <help-fs-for> ( vocab-names -- fs )
    H{ } clone :> index
    vocab-names [| name |
        t load-help? [ name require ] with-variable
        name vocab-words [ dup name>> help-filename swap ] H{ } map>assoc
        name help-filename index set-at
    ] each
    help-fs new index >>vocabularies H{ } clone >>rendered ;

: <help-fs> ( -- fs ) loaded-vocab-names <help-fs-for> ;

:: help-path ( path fs -- node )
    path "/" head? [ ENOENT fuse-fail ] unless
    fs vocabularies>> :> node!
    path "/" = [
        path rest "/" split [| component |
            node word? [ ENOTDIR fuse-fail ] when
            component node at dup [ ENOENT fuse-fail ] unless node!
        ] each
    ] unless
    node ;

:: help-content ( word fs -- bytes )
    word fs rendered>> [ word-help-bytes ] cache ;

M:: help-fs fs-getattr ( path fs -- entry )
    path fs help-path :> node
    node word? [ f node fs help-content length ] [ t 0 ] if
    <fuse-entry> ;

M:: help-fs fs-readdir ( path fs -- names )
    path fs help-path :> node
    node word? [ ENOTDIR fuse-fail ] when
    node keys sort ;

M:: help-fs fs-read ( path size offset fs -- bytes )
    path fs help-path :> node
    node word? [ EISDIR fuse-fail ] unless
    node fs help-content size offset fuse-slice ;

: mount-help ( mountpoint -- ) <help-fs> swap mount-fuse ;

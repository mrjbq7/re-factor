
USING: accessors arrays kernel make quotations sequences
slots words ;

IN: accessors.maybe

: maybe-word ( name -- word )
    "maybe-" prepend "accessors" create-word ;

: define-maybe ( name -- )
    dup maybe-word dup deferred? [
        [
            over setter-word \ drop 2array >quotation
            [ keep ] curry , \ compose ,
            swap reader-word [ dup ] swap 1quotation compose
            [ [ nip ] ] compose , \ dip , \ if* ,
        ] [ ] make ( object quot: ( -- x ) -- value ) define-inline
    ] [ 2drop ] if ;

: define-maybe-accessors ( class -- )
    "slots" word-prop [
        dup read-only>> [ drop ] [ name>> define-maybe ] if
    ] each ;

! <<
! TUPLE: test a b c ;
! test define-maybe-accessors
! >>


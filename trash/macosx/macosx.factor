! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.strings classes.struct core-services
io.encodings.utf8 kernel system trash ;

IN: trash.macosx

<PRIVATE

: check-err ( err -- )
    dup noErr = [ drop ] [
        GetMacOSStatusCommentString utf8 alien>string throw
    ] if ;

: <fs-ref> ( path -- fs-ref )
    utf8 string>alien
    kFSPathMakeRefDoNotFollowLeafSymlink
    FSRef <struct>
    [ f FSPathMakeRefWithOptions check-err ] keep ;

PRIVATE>

M: macosx send-to-trash ( path -- )
    <fs-ref> f kFSFileOperationDefaultOptions
    FSMoveObjectToTrashSync check-err ;



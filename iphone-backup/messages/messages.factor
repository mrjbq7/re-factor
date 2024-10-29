! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs colors combinators db db.sqlite
db.tuples db.types io io.directories io.files.info
io.files.unique io.pathnames io.styles iphone-backup kernel
math.statistics sequences sorting utils ;

IN: iphone-backup.messages

CONSTANT: messages-db "3d0d7e5fb2ce288813306e4d4636395e047a3d28"

: last-messages ( -- path )
    last-backup messages-db append-path ;

: with-messages-db ( quot -- )
    [ last-messages ] dip with-copy-sqlite-db ; inline

TUPLE: message rowid address date text flags replace svc-center
group-id association-id height ui-flags version subject country
headers recipients read? ;

message "message" {
    { "rowid" "ROWID" +db-assigned-id+ }
    { "address" "address" TEXT }
    { "date" "date" INTEGER }
    { "text" "text" TEXT }
    { "flags" "flags" INTEGER }
    { "replace" "replace" INTEGER }
    { "svc-center" "svc_center" TEXT }
    { "group-id" "group_id" INTEGER }
    { "association-id" "association_id" INTEGER }
    { "height" "height" INTEGER }
    { "ui-flags" "UIFlags" INTEGER }
    { "version" "version" INTEGER }
    { "subject" "subject" TEXT }
    { "country" "country" TEXT }
    { "headers" "headers" BLOB }
    { "recipients" "recipients" BLOB }
    { "read?" "read" INTEGER }
} define-persistent

TUPLE: group-member rowid group-id address country ;

group-member "group_member" {
    { "rowid" "ROWID" +db-assigned-id+ }
    { "group-id" "group_id" INTEGER }
    { "address" "address" TEXT }
    { "country" "country" TEXT }
} define-persistent

TUPLE: msg-group rowid type newest-message unread-count hash ;

msg-group "msg_group" {
    { "rowid" "ROWID" +db-assigned-id+ }
    { "type" "type" INTEGER }
    { "newest-message" "newest_message" INTEGER }
    { "unread-count" "unread_count" INTEGER }
    { "hash" "hash" INTEGER }
} define-persistent

: count-messages ( -- n )
    T{ message } count-tuples ;

: all-messages ( -- messages )
    T{ message } select-tuples ;

: sent-messages ( -- messages )
    T{ message { flags 3 } } select-tuples ;

: unread-messages ( -- messages )
    T{ message { flags 2 } { read? 0 } } select-tuples ;

: messages-from ( addr -- messages )
    message new swap >>address select-tuples ;

: group-members ( group-id -- group )
    group-member new swap >>group-id select-tuples ;

: all-group-members  ( -- groups )
    T{ group-member } select-tuples ;

: all-conversations ( -- conversations )
    all-messages [ group-id>> ] collect-by ;

USE: io
USE: io.styles
USE: combinators
USE: colors

<PRIVATE

CONSTANT: US H{
    { page-color COLOR: gray }
    { border-color COLOR: dark-slate-gray }
    { wrap-margin 500 }
    { inset { 10 10 } }
}

CONSTANT: THEM H{
    { page-color COLOR: green }
    { border-color COLOR: dark-green }
    { wrap-margin 500 }
    { inset { 10 10 } }
}

PRIVATE>

: print-messages ( messages -- )
    [
        [ text>> ] [
            nl flags>> {
                { 3 [ US " " write ] }
                { 2 [ THEM "    " write ] }
                [ drop f ]
            } case
        ] bi [ [ write ] when* ] with-nesting nl
    ] each ;


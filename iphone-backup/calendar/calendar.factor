! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs db db.sqlite db.tuples db.types
io.directories io.files.info io.files.unique io.pathnames
iphone-backup kernel sequences sets sorting urls utils ;

IN: iphone-backup.calendar

CONSTANT: calendar-db "2041457d5fe04d39d0ab481178355df6781e6858"

: last-calendar ( -- path )
    last-backup calendar-db append-path ;

: with-calendar-db ( quot -- )
    [ last-calendar ] dip with-copy-sqlite-db ; inline

TUPLE: event rowid summary location description start-date
start-tz end-date all-day? calendar-id orig-event-id
orig-start-date organizer-id organizer-is-self?
organizer-external-id self-attendee-id status availability
privacy-level url last-modified sequence-num birthday-id
modified-properties external-tracking-status external-id
external-mod-tag unique-identifier external-schedule-id
external-rep response-comment hidden? ;

! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays colors colors.constants kernel smtp ui
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.labels ui.gadgets.scrollers
ui.gadgets.tracks ui.pens.solid ;

IN: mail-ui

TUPLE: mail-gadget < track to subject body ;

M: mail-gadget focusable-child* to>> ;

: <to> ( mail -- gadget )
    to>> "To:" label-on-left ;

: <subject> ( mail -- gadget )
    subject>> "Subject:" label-on-left ;

: <body> ( mail -- gadget )
    body>> <scroller> COLOR: gray <solid> >>boundary ;

: com-send ( mail -- )
    <email>
        over to>> editor-string 1array >>to
        over subject>> editor-string >>subject
        over body>> editor-string >>body
    send-email close-window ;

: com-cancel ( mail -- )
    close-window ;

mail-gadget "toolbar" f {
    { f com-send }
    { f com-cancel }
} define-command-map

: <mail-gadget> ( -- gadget )
    vertical mail-gadget new-track
        1 >>fill
        { 10 10 } >>gap

        <editor> >>to
        <editor> >>subject
        <multiline-editor>
            10 >>min-rows
            60 >>min-cols
            >>body

        dup <to>      f track-add
        dup <subject> f track-add
        dup <body>    1 track-add
        dup <toolbar> f track-add ;

: open-compose-window ( -- )
    <mail-gadget>
        { 5 5 } <border> { 1 1 } >>fill
    "Compose" open-window ;

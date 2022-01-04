! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays colors kernel sequences smtp splitting
ui ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.labels ui.gadgets.scrollers
ui.gadgets.toolbar ui.gadgets.tracks ui.gadgets.worlds
ui.gestures ui.pens.solid ;

IN: mail-ui

<PRIVATE

TUPLE: tabbing-editor < editor next-editor prev-editor ;

: <tabbing-editor> ( -- editor )
    tabbing-editor new-editor ;

TUPLE: tabbing-multiline-editor < multiline-editor next-editor prev-editor ;

: <tabbing-multiline-editor> ( -- editor )
    tabbing-multiline-editor new-editor ;

: com-prev ( editor -- )
    prev-editor>> [ request-focus ] when* ;

: com-next ( editor -- )
    next-editor>> [ request-focus ] when* ;

tabbing-editor tabbing-multiline-editor [
    "editing" f {
        { T{ key-down f f "TAB" } com-next }
        { T{ key-down f { S+ } "TAB" } com-prev }
    } define-command-map
] bi@

PRIVATE>

TUPLE: mail-gadget < track to subject body ;

M: mail-gadget focusable-child* to>> ;

: <to> ( mail -- gadget )
    to>> "To:" label-on-left ;

: <subject> ( mail -- gadget )
    subject>> "Subject:" label-on-left ;

: <body> ( mail -- gadget )
    body>> <scroller> COLOR: gray <solid> >>boundary ;

<PRIVATE

: maybe-close-window ( gadget -- )
    dup parents 3 head [ world? ] find nip
    [ close-window ] [ drop ] if ;

PRIVATE>

: com-send ( mail -- )
    <email>
        over to>> editor-string " " split harvest >>to
        over subject>> editor-string >>subject
        over body>> editor-string >>body
    send-email maybe-close-window ;

: com-cancel ( mail -- )
    maybe-close-window ;

mail-gadget "toolbar" f {
    { f com-send }
    { f com-cancel }
} define-command-map

: <mail-gadget> ( -- gadget )
    vertical mail-gadget new-track
        1 >>fill
        { 10 10 } >>gap

        <tabbing-editor> >>to
        <tabbing-editor> >>subject
        <tabbing-multiline-editor>
            10 >>min-rows
            60 >>min-cols
            >>body

        dup to>> over subject>> >>next-editor drop
        dup to>> over body>> >>prev-editor drop

        dup subject>> over body>> >>next-editor drop
        dup subject>> over to>> >>prev-editor drop

        dup body>> over subject>> >>prev-editor drop

        dup <to>      f track-add
        dup <subject> f track-add
        dup <body>    1 track-add
        dup <toolbar> f track-add ;

: open-compose-window ( -- )
    <mail-gadget>
        { 5 5 } <border> { 1 1 } >>fill
    "Compose" open-window ;

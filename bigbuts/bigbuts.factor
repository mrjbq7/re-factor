! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs calendar checksums
checksums.sha combinators command-line continuations fonts fry
hex-strings io io.backend io.directories io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.launcher
io.pathnames kernel libc locals math namespaces sequences
sequences.generalizations serialize splitting strings timers ui
ui.gadgets ui.gadgets.buttons ui.gadgets.labels ui.gadgets.tracks
ui.gadgets.worlds ui.gestures unix.ffi ;
FROM: io => write flush ;
IN: bigbuts

ERROR: invalid-bigbuts-command line ;
ERROR: empty-bigbuts-config ;
ERROR: invalid-bigbuts-option option ;

: trim-command ( string -- string' ) [ blank? ] trim ;

: parse-command ( line -- pair/f )
    trim-command dup [ empty? ] [ "#" head? ] bi or
    [ drop f ] [
        dup ":" split1 dup [
            [ nip trim-command ] dip trim-command
        ] [
            2drop dup [ blank? ] split-when harvest first swap
        ] if
        2dup [ empty? ] either? [ 2array invalid-bigbuts-command ] when
        2array
    ] if ;

: parse-commands ( text -- commands )
    split-lines [ parse-command ] map sift
    dup empty? [ empty-bigbuts-config ] when ;

TUPLE: bigbuts-options file log-directory no-geometry? help? ;

:: parse-options ( args -- options )
    bigbuts-options new :> options
    args :> remaining!
    [ remaining empty? not ] [
        remaining unclip swap remaining! :> arg
        arg {
            { "-h" [ options t >>help? drop ] }
            { "--help" [ options t >>help? drop ] }
            { "-g" [ options t >>no-geometry? drop ] }
            { "--no-geometry" [ options t >>no-geometry? drop ] }
            { "-l" [
                remaining empty? [ arg invalid-bigbuts-option ] when
                remaining unclip swap remaining! options swap >>log-directory drop
            ] }
            { "--log" [
                remaining empty? [ arg invalid-bigbuts-option ] when
                remaining unclip swap remaining! options swap >>log-directory drop
            ] }
            [
                dup "-" = over "-" head? not or
                options file>> not and
                [ options swap >>file drop ] [ invalid-bigbuts-option ] if
            ]
        } case
    ] while options ;

! Arguments are passed separately, never interpolated into shell source.
: command-argv ( command log-directory/f -- argv )
    [
        [ "/bin/bash" "-c"
          "/bin/sh -c \"$2\" > >(tee -- \"$1/$$.stdout\") 2> >(tee -- \"$1/$$.stderr\" >&2); result=$?; wait; exit \"$result\""
          "bigbuts" ] 2dip swap 6 narray
    ] [ "/bin/sh" "-c" rot 3array ] if* ;

: launch-command ( command log-directory/f -- process )
    command-argv <process> swap >>command
    +new-group+ >>group run-detached ;

TUPLE: bigbuts-state commands children log-directory interrupted? cache-file ;

: <bigbuts-state> ( commands log-directory -- state )
    bigbuts-state new swap >>log-directory swap >>commands
    V{ } clone >>children ;

:: run-button ( command state -- )
    state f >>interrupted? drop
    state children>> [ process-running? ] filter! drop
    "\n-----(bigbuts) Starting: " write command print flush
    command state log-directory>> launch-command
    state children>> push ;

:: interrupt-children ( state -- )
    state interrupted?>> [ SIGKILL ] [ SIGINT ] if :> signal
    state children>> [ process-running? ] filter! [
        handle>> signal killpg 0 <
        [ "-----(bigbuts) Process exited before signal delivery." print ] when
    ] each
    state t >>interrupted? drop flush ;

TUPLE: bigbuts-track < track state { rotation initial: 0 } ;
TUPLE: bigbuts-world < world state save-timer last-geometry ;

: space-output ( state -- )
    f >>interrupted? drop 15 [ nl ] times flush ;

:: rotate-buttons ( gadget -- )
    gadget state>> f >>interrupted? drop
    gadget [ 1 + 4 mod ] change-rotation drop
    gadget rotation>> { { 1 0 } { 0 1 } { 1 0 } { 0 1 } } nth gadget swap >>orientation drop
    gadget rotation>> even? [ gadget children>> reverse! drop ] when
    gadget relayout ;

bigbuts-track H{
    { T{ key-down f { C+ } "c" } [ state>> interrupt-children ] }
    { T{ key-down f f "TAB" } [ rotate-buttons ] }
    { T{ key-down f f "r" } [ rotate-buttons ] }
    { mouse-scroll [ state>> space-output ] }
} set-gestures

:: <bigbuts-track> ( state -- gadget )
    horizontal bigbuts-track new-track state >>state { 2 2 } >>gap :> track
    state commands>> [ first2 :> ( label command )
        label <label> dup font>> clone 28 >>size >>font
        [ drop command state run-button ] <border-button>
        { 20 20 } >>size { 1 1 } >>fill
        track swap 1 track-add drop
    ] each track ;

: geometry-file ( key -- path )
    utf8 encode sha-256 checksum-bytes bytes>hex-string
    ".geometry" append "~/.bigbuts/" prepend normalize-path ;

: world-geometry ( world -- geometry )
    [ window-loc>> ] [ dim>> ]
    [ children>> first rotation>> ] tri 3array ;

:: save-geometry ( world -- )
    world world-geometry :> geometry
    geometry world last-geometry>> = [ ] [
        [
            world state>> cache-file>> :> path
            path parent-directory make-directories
            geometry object>bytes path binary set-file-contents
            world geometry >>last-geometry drop
        ] [ drop ] recover
    ] if ;

M: bigbuts-world ungraft*
    dup save-timer>> [ stop-timer ] when*
    dup save-geometry call-next-method ;

:: restore-geometry ( world -- )
    [
        world state>> cache-file>> binary file-contents bytes>object
        first3 :> ( loc dim rotation )
        loc length 2 = dim length 2 = and
        loc [ number? ] all? and dim [ dup number? [ 0 > ] [ drop f ] if ] all? and
        rotation { 0 1 2 3 } member? and [
            world loc >>window-loc dim >>pref-dim drop
            rotation [ world children>> first rotate-buttons ] times
        ] when
    ] [ drop ] recover ;

:: open-bigbuts ( commands options -- )
    options log-directory>> [ normalize-path dup make-directories ] [ f ] if* :> logs
    commands logs <bigbuts-state> :> state
    options file>> dup [ "-" = not ] [ drop f ] if
    [ options file>> normalize-path ] [ commands object>bytes bytes>hex-string ] if
    geometry-file state swap >>cache-file drop
    state <bigbuts-track> :> track
    <world-attributes> bigbuts-world >>world-class "BigButs" >>title
    track >>gadgets { 600 160 } >>pref-dim <world> state >>state :> world
    options no-geometry?>> [ world restore-geometry ] unless
    world open-world-window
    world [ world save-geometry ] 1 seconds every >>save-timer drop ;

: bigbuts-usage ( -- )
    "Usage: bigbuts [-g|--no-geometry] [-l|--log DIRECTORY] [FILE|-]" print
    "Read label: command lines from FILE or stdin. Blank lines and # comments are ignored." print
    "Tab/R: rotate. Ctrl-C: interrupt; repeat to kill. Mouse wheel: output spacing." print ;

: bigbuts ( -- )
    command-line get parse-options dup help?>> [ drop bigbuts-usage ] [
        dup file>> dup [ "-" = not ] [ drop f ] if
        [ dup file>> utf8 file-contents ] [ read-contents ] if
        parse-commands swap [ open-bigbuts ] 2curry with-ui
    ] if ;

FROM: io => write flush ;
MAIN: bigbuts

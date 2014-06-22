USING: accessors assocs classes.tuple colors.constants
formatting http.client io io.styles json.reader kernel locals
math.parser sequences ;

IN: worldcup

TUPLE: game home_team home_team_events home_team_tbd
away_team away_team_events away_team_tbd winner match_number
datetime location status ;

: worldcup ( -- games )
    "http://worldcup.sfg.io/matches" http-get nip json>
    [ game from-slots ] map ;

: completed-games ( games -- games' )
    [ status>> "completed" = ] filter ;

CONSTANT: winner-style H{
    { foreground COLOR: MediumSeaGreen }
    { font-style bold }
}

: game. ( game -- )
    [let
        [ home_team>> ] [ away_team>> ] [ winner>> ] tri
            :> ( home away winner )

        home "country" of dup winner =
        [ winner-style format ] [ write ] if bl
        home "goals" of number>string write

        " x " write

        away "country" of dup winner =
        [ winner-style format ] [ write ] if bl
        away "goals" of number>string write nl
    ] ;

: worldcup. ( -- )
    worldcup completed-games [ game. ] each ;

! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar calendar.format
combinators csv formatting fry grouping http.client io io.styles
kernel math math.extras math.parser namespaces regexp sequences
sorting splitting urls wrap.strings ;

IN: metar

TUPLE: station cccc name state country latitude longitude ;

C: <station> station

: string>longitude ( str -- lon )
    "-" split1 unclip-last
    [ [ string>number ] bi@ 60.0 / + ]
    [ CHAR: W = [ neg ] when ] bi* ;

: string>latitude ( str -- lat )
    "-" split1 unclip-last
    [ [ string>number ] bi@ 60.0 / + ]
    [ CHAR: S = [ neg ] when ] bi* ;

: load-stations ( -- seq )
    URL" http://weather.noaa.gov/data/nsd_cccc.txt"
    http-get nip CHAR: ; [ string>csv ] with-delimiter
    [
        {
            [ 0 swap nth ]
            [ 3 swap nth ]
            [ 4 swap nth ]
            [ 5 swap nth ]
            [ 7 swap nth string>latitude ]
            [ 8 swap nth string>longitude ]
        } cleave <station>
    ] map ;

: get-metar ( station -- metar )
    "http://weather.noaa.gov/pub/data/observations/metar/stations/%s.TXT"
    sprintf http-get nip ;

<PRIVATE

TUPLE: report type station timestamp modifier wind visibility
rvr weather sky-condition temperature dew-point altimeter
remarks raw ;

CONSTANT: pressure-tendency H{
    { "0" "increasing then decreasing" }
    { "1" "increasing more slowly" }
    { "2" "increasing" }
    { "3" "increasing more quickly" }
    { "4" "steady" }
    { "5" "decreasing then increasing" }
    { "6" "decreasing more slowly" }
    { "7" "decreasing" }
    { "8" "decreasing more quickly" }
}

CONSTANT: lightning H{
    { "CA" "cloud-air lightning" }
    { "CC" "cloud-cloud lightning" }
    { "CG" "cloud-ground lightning" }
    { "IC" "in-cloud lightning" }
}

CONSTANT: abbreviations H{
    { "$" "maintenance check indicator" }
    { "+" "heavy intensity" }
    { "+FC" "tornado or waterspout" }
    { "-" "light intensity" }
    { "/" "indicator that visual range data follows; separator between temperature and dew point data." }
    { "ACC" "altocumulus castellanus" }
    { "ACFT" "aircraft" }
    { "ACSL" "standing lenticular altocumulus" }
    { "ALP" "aircraft location point" }
    { "ALQDS" "All Quadrants" } ! (Official)
    { "ALQS" "All Quadrants" } ! (Unofficial)
    { "AMB" "amber" }
    { "AND" "and" }
    { "AO1" "station without a precipitation descriminator" }
    { "AO2" "station with a precipitation descriminator" }
    { "APCH" "approach" }
    { "APRNT" "apparent" }
    { "APRX" "approximately" }
    { "ATCT" "airport traffic control tower" }
    { "AUTO" "automated report" }
    { "B" "began" }
    { "BC" "patches" }
    { "BINOVC" "breaks in overcast" }
    { "BKN" "broken" }
    { "BL" "blowing" }
    { "BLU" "blue" }
    { "BR" "mist" }
    { "BYD" "by day" }
    { "C" "center" }
    { "CAVOK" "clear skies and unlimited visibility" }
    { "CB" "cumulonimbus cloud" }
    { "CBMAM" "cumulonimbus mammatus cloud" }
    { "CCSL" "cirrocumulus standing lenticular cloud" }
    { "CD" "candela" }
    { "CHI" "cloud-height indicator" }
    { "CHINO" "sky condition at secondary location not available" }
    { "CIG" "ceiling" }
    { "CLR" "clear sky" }
    { "CNTRLN" "centerline" }
    { "CONS" "continuous" }
    { "COR" "correction to a previously disseminated observation" }
    { "CU" "cumulus" }
    { "DEGS" "degrees" }
    { "DOC" "Department of Commerce" }
    { "DOD" "Department of Defense" }
    { "DOT" "Department of Transportation" }
    { "DR" "low drifting" }
    { "DS" "duststorm" }
    { "DSIPTG" "dissipating" }
    { "DSNT" "distant" }
    { "DU" "widespread dust" }
    { "DVR" "dispatch visual range" }
    { "DZ" "drizzle" }
    { "E" "east" }
    { "FAA" "Federal Aviation Administration" }
    { "FC" "funnel cloud" }
    { "FEW" "few" }
    { "FG" "fog" }
    { "FIBI" "filed but impracticable to transmit" }
    { "FIRST" "first observation after a break in coverage at manual station" }
    { "FMH-1" "Federal Meteorological Handbook No.1, Surface Weather Observations & Reports (METAR)" }
    { "FMH2" "Federal Meteorological Handbook No.2, Surface Synoptic Codes" }
    { "FROIN" "Frost On The Indicator" }
    { "FROPA" "frontal passage" }
    { "FRQ" "frequent" }
    { "FT" "feet" }
    { "FU" "smoke" }
    { "FZ" "freezing" }
    { "FZRANO" "freezing rain sensor not available" }
    { "GR" "hail" }
    { "GRN" "green" }
    { "GS" "small hail and/or snow pellets" }
    { "HLSTO" "hailstone" }
    { "HZ" "haze" }
    { "IC" "ice crystals" }
    { "ICAO" "International Civil Aviation Organization" }
    { "INCRG" "increasing" }
    { "INTMT" "intermittent" }
    { "INVOF" "in vicinity of" }
    { "KT" "knots" }
    { "L" "left" }
    { "LAST" "last observation before a break in coverage at a manual station" }
    { "LST" "Local Standard Time" }
    { "LTG" "lightning" }
    { "LWR" "lower" }
    { "M" "minus, less than" }
    { "MAX" "maximum" }
    { "METAR" "aviation routine weather report" }
    { "MI" "shallow" }
    { "MIN" "minimum" }
    { "MOV" "moved/moving/movement" }
    { "MOVD" "moved" }
    { "MSHP" "mishap" }
    { "MT" "mountains" }
    { "N" "north" }
    { "N/A" "not applicable" }
    { "NCD" "clear sky" }
    { "NCDC" "National Climatic Data Center" }
    { "NE" "northeast" }
    { "NOS" "National Ocean Survey" }
    { "NOSIG" "no significant change is expected in next 2 hours" }
    { "NOSPECI" "no SPECI reports are taken at the station" }
    { "NOTAM" "Notice to Airmen" }
    { "NSC" "clear sky" }
    { "NW" "northwest" }
    { "NWS" "National Weather Service" }
    { "OCNL" "occasional" }
    { "OFCM" "Office of the Federal Coordinator for Meteorology" }
    { "OHD" "overhead" }
    { "OVC" "overcast" }
    { "OVR" "over" }
    { "P" "greater than" }
    { "PCPN" "precipitation" }
    { "PK" "peak" }
    { "PL" "ice pellets" }
    { "PNO" "precipitation amount not available" }
    { "PO" "well-developed dust/sand whirls" }
    { "PR" "partial" }
    { "PRES" "Atmospheric pressure" }
    { "PRESFR" "pressure falling rapidly" }
    { "PRESRR" "pressure rising rapidly" }
    { "PWINO" "precipitation identifier sensor not available" }
    { "PY" "spray" }
    { "R" "right" }
    { "RA" "rain" }
    { "RED" "red" }
    { "RTD" "Routine Delayed (late) observation" }
    { "RV" "reportable value" }
    { "RVR" "Runway visual range" }
    { "RVRNO" "RVR system values not available" }
    { "RWY" "runway" }
    { "RY" "runway" }
    { "S" "south" }
    { "SA" "sand" }
    { "SC" "stratocumulus" }
    { "SCSL" "stratocumulus standing lenticular cloud" }
    { "SCT" "scattered" }
    { "SE" "southeast" }
    { "SFC" "surface" }
    { "SG" "snow grains" }
    { "SH" "shower(s)" }
    { "SKC" "clear sky" }
    { "SLP" "sea-level pressure" }
    { "SLPNO" "sea-level pressure not available" }
    { "SM" "statute miles" }
    { "SN" "snow" }
    { "SNINCR" "snow increasing rapidly" }
    { "SOG" "Snow on the ground" }
    { "SPECI" "an unscheduled report taken when certain criteria have been met" }
    { "SQ" "squalls" }
    { "SS" "sand storm" }
    { "STN" "station" }
    { "SW" "southwest" }
    { "TCU" "towering cumulus" }
    { "THLD" "threshold" }
    { "TS" "thunderstorm" }
    { "TSNO" "thunderstorm information not available" }
    { "TWR" "tower" }
    { "UNKN" "unknown" }
    { "UNUSBL" "unusable" }
    { "UP" "unknown precipitation" }
    { "UTC" "Coordinated Universal Time" }
    { "V" "variable" }
    { "VA" "volcanic ash" }
    { "VC" "in the vicinity" }
    { "VIRGA" "virga" }
    { "VIS" "visibility" }
    { "VISNO" "visibility at secondary location not available" }
    { "VR" "visual range" }
    { "VRB" "variable" }
    { "VV" "vertical visibility" }
    { "W" "west" }
    { "WG/AOS" "Working Group for Atmospheric Observing Systems" }
    { "WG/SO" "Working Group for Surface Observations" }
    { "WHT" "white" }
    { "WMO" "World Meteorological Organization" }
    { "WND" "wind" }
    { "WS" "wind shear" }
    { "WSHFT" "wind shift" }
    { "YLO" "yellow" }
    { "Z" "zulu (i.e. Coordinated Universal Time)" }
}

: split-abbreviations ( str -- seq )
    abbreviations >alist [ first length ] inv-sort-with
    keys '[
        [ dup empty? not ] [
            dup first digit? [
                dup [ digit? not ] find drop
                [ cut swap ] [ f swap ] if*
            ] [
                _ [ dupd head? ] find nip
                [ [ ?head drop ] keep ] [ f swap ] if*
            ] if
        ] produce nip
    ] call ;

: parse-abbreviations ( str -- str' )
    split-abbreviations [ abbreviations ?at drop ] map " " join ;

: metar>timestamp ( str -- timestamp )
    [ now [ year>> ] [ month>> ] bi ] dip
    2 cut 2 cut 2 cut drop [ string>number ] tri@
    0 instant <timestamp> ;

: parse-timestamp ( report str -- report )
    metar>timestamp >>timestamp ;

CONSTANT: compass-directions H{
    { 0 "N" }
    { 22.5 "NNE" }
    { 45.0 "NE" }
    { 67.5 "ENE" }
    { 90.0 "E" }
    { 112.5 "ESE" }
    { 135.0 "SE" }
    { 157.5 "SSE" }
    { 180.0 "S" }
    { 202.5 "SSW" }
    { 225.0 "SW" }
    { 247.5 "WSW" }
    { 270.0 "W" }
    { 292.5 "WNW" }
    { 315.0 "NW" }
    { 337.5 "NNW" }
    { 360.0 "N" }
}

: direction>compass ( direction -- compass )
    22.5 round-to-step compass-directions at ;

: append-to ( str -- quot )
    '[ _ "" append-as ] ; inline

: glue-to ( str -- quot )
    '[  _ swap [ swap ", " glue ] unless-empty ] ; inline

: parse-direction ( str -- str' )
    dup "VRB" = [ drop "variable" ] [
        string>number [ direction>compass ] keep
        "from %s (%s degrees)" sprintf
    ] if ;

: parse-wind ( str -- str' )
    dup "00000KT" = [ drop "calm" ] [
        3 cut "KT" ?tail drop
        [ parse-direction ] [ string>number ] bi*
        "%s at %s knots" sprintf
    ] if ;

: parse-wind-gust ( str -- str' )
    3 cut "KT" ?tail drop "G" split1
    [ parse-direction ] [ string>number ] [ string>number ] tri*
    "%s at %s knots with gusts to %s knots" sprintf ;

: parse-wind-variable ( str -- str' )
    "V" split1 [ string>number ] bi@
    ", variable from %s to %s" sprintf ;

: parse-visibility ( str -- str' )
    "M" ?head "less than " "" ? swap "SM" ?tail drop
    CHAR: / over index [ 1 > [ 1 cut "+" glue ] when ] when*
    string>number "%s%s statute miles" sprintf ;

: parse-rvr ( str -- str' )
    "R" ?head drop "/" split1 "FT" ?tail drop
    "V" split1 [
        [ string>number ] bi@
        "varying between %s and %s" sprintf
    ] [
        string>number "of %s" sprintf
    ] if* "runway %s visibility %s ft" sprintf ;

: parse-weather ( str -- str' )
    parse-abbreviations ;

: parse-sky-condition ( str -- str' )
    dup abbreviations at [ nip ] [
        3 cut 3 cut
        [ abbreviations at ]
        [ string>number " at %s00 ft" sprintf ]
        [ abbreviations at [ " (%s)" sprintf ] [ f ] if* ]
        tri* 3append
    ] if* ;

: parse-temperature ( report str -- report )
    "/" split1
    [ "M" ?head [ string>number ] [ [ neg ] when ] bi* ] bi@
    [ >>temperature ] [ >>dew-point ] bi* ;

: parse-altimeter ( report str -- report )
    unclip [ string>number ] [ CHAR: A = ] bi*
    [ 100 /f "%.2f Hg" sprintf ]
    [ "%s mb" sprintf ] if >>altimeter ;

CONSTANT: re-timestamp R! \d{6}Z!
CONSTANT: re-station R! \w{4}!
CONSTANT: re-temperature R! [M]?\d{2}/[M]?\d{2}!
CONSTANT: re-wind R! (VRB|\d{3})\d{2,3}KT!
CONSTANT: re-wind-gust R! \d{3}\d{2,3}G\d{2,3}KT!
CONSTANT: re-wind-variable R! \d{3}V\d{3}!
CONSTANT: re-visibility R! [M]?\d+(/\d+)?SM!
CONSTANT: re-rvr R! R\d{2}[RLC]?/\d{4}(V\d{4})?FT!
CONSTANT: re-weather R! [+-]?(VC)?(\w\w)?\w\w!
CONSTANT: re-sky-condition R! (\w{3}\d{3}(\w+)?|\w{3}|CAVOK)!
CONSTANT: re-altimeter R! [AQ]\d{4}!

: parse-body ( report seq -- report )
    [
        {
            { [ dup { "METAR" "SPECI" } member? ] [ >>type ] }
            { [ dup { "AUTO" "COR" } member? ] [ >>modifier ] }
            { [ dup re-station matches? pick station>> not and ] [ >>station ] }
            { [ dup re-visibility matches? ] [
                parse-visibility >>visibility ] }
            { [ dup re-timestamp matches? ] [ parse-timestamp ] }
            { [ dup re-wind matches? ] [
                parse-wind append-to change-wind ] }
            { [ dup re-wind-gust matches? ] [
                parse-wind-gust append-to change-wind ] }
            { [ dup re-wind-variable matches? ] [
                parse-wind-variable append-to change-wind ] }
            { [ dup re-rvr matches? ] [
                parse-rvr glue-to change-rvr ] }
            { [ dup re-weather matches? ] [
                parse-weather glue-to change-weather ] }
            { [ dup re-sky-condition matches? ] [
                parse-sky-condition glue-to change-sky-condition ] }
            { [ dup re-temperature matches? ] [ parse-temperature ] }
            { [ dup re-altimeter matches? ] [ parse-altimeter ] }
            [ drop ]
        } cond
    ] each ;

: signed-number ( sign value -- n )
    [ string>number ] bi@ swap zero? [ neg ] unless 10.0 / ;

: single-value ( str -- str' )
    1 cut signed-number ;

: double-value ( str -- m n )
    1 cut 3 cut [ signed-number ] dip 1 cut signed-number ;

: parse-1hr-temp ( str -- str' )
    "T" ?head drop double-value
    "hourly temperature %s and dew point %s" sprintf ;

: parse-6hr-max-temp ( str -- str' )
    "1" ?head drop single-value
    "6-hourly maximum temperature %s" sprintf ;

: parse-6hr-min-temp ( str -- str' )
    "2" ?head drop single-value
    "6-hourly minimum temperature %s" sprintf ;

: parse-24hr-temp ( str -- str' )
    "4" ?head drop double-value
    "24-hour maximum temperature %s minimum temperature %s"
    sprintf ;

: parse-1hr-pressure ( str -- str' )
    "5" ?head drop 1 cut single-value [ pressure-tendency at ] dip
    "hourly pressure %s %s mb" sprintf ;

: parse-snow-depth ( str -- str' )
    "4/" ?head drop string>number "snow depth %s inches" sprintf ;

: parse-inches ( str -- str' )
    string>number
    [ "trace" ] [ 100 /f "%s inches" sprintf ] if-zero ;

: parse-1hr-precipitation ( str -- str' )
    "P" ?head drop parse-inches
    "%s precipitation in last hour" sprintf ;

: parse-6hr-precipitation ( str -- str' )
    "6" ?head drop parse-inches
    "%s precipitation in last 6 hours" sprintf ;

: parse-24hr-precipitation ( str -- str' )
    "7" ?head drop parse-inches
    "%s precipitation in last 24 hours" sprintf ;

: parse-recent-time ( str -- str' )
    dup length 2 >
    [ 2 cut ":" glue ]
    [ " minutes past the hour" append ] if ;

: parse-peak-wind ( str -- str' )
    3 cut "/" split1 [ [ string>number ] bi@ ] dip
    parse-recent-time
    "from %s at %s knots occuring at %s" sprintf ;

: parse-sea-level-pressure ( str -- str' )
    "SLP" ?head drop string>number 10.0 /f 1000 +
    "sea-level pressure is %s hPa" sprintf ;

: parse-lightning ( str -- str' )
    "LTG" ?head drop 2 group [ lightning at ] map " " join ;

CONSTANT: re-recent-weather R! \w{2}[BE]\d{2,4}((\w{2})?[BE]\d{2,4})?!
CONSTANT: re-began/ended R! [BE]\d{2,4}!

: parse-began/ended ( str -- str' )
    unclip swap
    [ CHAR: B = "began" "ended" ? ]
    [ parse-recent-time ] bi* "%s at %s" sprintf ;

: (parse-recent-weather) ( str -- str' )
    dup [ digit? ] find drop 2 > [
        2 cut [ abbreviations at " " append ] dip
    ] [ f swap ] if parse-began/ended "" append-as ;

: parse-recent-weather ( str -- str' )
    dup [ digit? ] find drop
    over [ digit? not ] find-from drop [
        cut [ (parse-recent-weather) ] bi@ " " glue
    ] [ (parse-recent-weather) ] if* ;

: parse-varying ( str -- str' )
    "V" split1 [ string>number ] bi@
    "varying between %s00 and %s00 ft" sprintf ;

: parse-from-to ( str -- str' )
    "-" split1 [ parse-abbreviations ] bi@ " to " glue ;

: parse-remarks ( report seq -- report )
    [
        {
            { [ dup R! 1\d{4}! matches? ] [ parse-6hr-max-temp ] }
            { [ dup R! 2\d{4}! matches? ] [ parse-6hr-min-temp ] }
            { [ dup R! 4\d{8}! matches? ] [ parse-24hr-temp ] }
            { [ dup R! 4/\d{3}! matches? ] [ parse-snow-depth ] }
            { [ dup R! 5\d{4}! matches? ] [ parse-1hr-pressure ] }
            { [ dup R! 6\d{4}! matches? ] [ parse-6hr-precipitation ] }
            { [ dup R! 7\d{4}! matches? ] [ parse-24hr-precipitation ] }
            { [ dup R! T\d{8}! matches? ] [ parse-1hr-temp ] }
            { [ dup R! \d{3}\d{2,3}/\d{2,4}! matches? ] [ parse-peak-wind ] }
            { [ dup R! P\d{4}! matches? ] [ parse-1hr-precipitation ] }
            { [ dup R! SLP\d{3}! matches? ] [ parse-sea-level-pressure ] }
            { [ dup R! LTG\w+! matches? ] [ parse-lightning ] }
            { [ dup R! \d{3}V\d{3}! matches? ] [ parse-varying ] }
            { [ dup R! [^-]+-[^-]+! matches? ] [ parse-from-to ] }
            { [ dup re-began/ended matches? ] [ parse-began/ended ] }
            { [ dup re-recent-weather matches? ] [ parse-recent-weather ] }
            { [ dup re-weather matches? ] [ parse-weather ] }
            { [ dup re-sky-condition matches? ] [ parse-sky-condition ] }
            [ parse-abbreviations ]
        } cond
    ] map " " join >>remarks ;

: <report> ( metar -- report )
    [ report new ] dip [ >>raw ] keep
    [ blank? ] split-when { "RMK" } split1
    [ parse-body ] [ parse-remarks ] bi* ;

: ?write ( seq -- )
    [ 65 wrap-string write ] when* ; inline

: named-row ( name quot -- )
    '[ [ _ write ] with-cell _ with-cell ] with-row ; inline

: report. ( report -- )
    [ raw>> ?write nl nl ] keep standard-table-style [
        {
            [ "Station" [ station>> ?write ] named-row ]
            [ "Timestamp" [ timestamp>> timestamp>rfc822 write ] named-row ]
            [ "Wind" [ wind>> ?write ] named-row ]
            [ "Visibility" [ visibility>> ?write ] named-row ]
            [ "RVR" [ rvr>> ?write ] named-row ]
            [ "Weather" [ weather>> ?write ] named-row ]
            [ "Sky condition" [ sky-condition>> ?write ] named-row ]
            [ "Temperature" [ temperature>> [ "%s °C" printf ] when* ] named-row ]
            [ "Dew point" [ dew-point>> [ "%s °C" printf ] when* ] named-row ]
            [ "Altimeter" [ altimeter>> [ ?write ] when* ] named-row ]
            [ "Remarks" [ remarks>> [ ?write nl ] when* ] named-row ]
        } cleave
    ] tabular-output nl ;

PRIVATE>

: metar. ( station -- )
    get-metar <report> report. ;

! TODO: numerical remarks:
! 8/765 Cloud cover using WMO Code.
! 98060 Duration of sunshine in minutes.
! 931222 Snowfall in the last 6-hours.
! 933021 Liquid water equivalent of the snow (SWE).

! TODO: calculate wind chill?
! http://en.wikipedia.org/wiki/Wind_chill
!   if (self.temp and self.temp <= 10 and
!      self.windspeed and (self.windspeed*3.6) > 4.8):
!      self.w_chill = (13.12 + 0.6215*self.temp -
!                      11.37*(self.windspeed*3.6)**0.16 +
!                      0.3965*self.temp*(self.windspeed*3.6)**0.16)


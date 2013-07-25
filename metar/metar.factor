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

: get-report ( station -- report )
    "http://weather.noaa.gov/pub/data/observations/metar/stations/%s.TXT"
    sprintf http-get nip ;

: metar>timestamp ( str -- timestamp )
    [ now [ year>> ] [ month>> ] bi ] dip
    2 cut 2 cut 2 cut drop [ string>number ] tri@
    0 instant <timestamp> ;

TUPLE: report type station timestamp modifier wind visibility
weather sky-condition temperature dew-point altimeter remarks
raw ;

<PRIVATE

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
    { "AO1" "station without a precipitation descriminator" }
    { "AO2" "station with a precipitation descriminator" }
    { "APCH" "approach" }
    { "APRNT" "apparent" }
    { "APRX" "approximately" }
    { "ATCT" "airport traffic control tower" }
    { "AUTO" "automated report" }
    { "B" "began" }
    { "BC" "patches" }
    { "BKN" "broken clouds" }
    { "BL" "blowing" }
    { "BLU" "blue" }
    { "BR" "mist" }
    { "BYD" "by day" }
    { "C" "center" }
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
    { "FEW" "few clouds" }
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
    { "RAE" "rain ended" }
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
    { "SCT" "scattered clouds" }
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
    { "TSE" "thunderstorm ended" }
    { "TSNO" "thunderstorm information not available" }
    { "TWR" "tower" }
    { "UNKN" "unknown" }
    { "UNUSBL" "unusable" }
    { "UP" "unknown precipitation" }
    { "UTC" "Coordinated Universal Time" }
    { "V" "variable" }
    { "VA" "volcanic ash" }
    { "VC" "in the vicinity" }
    { "VIS" "visibility" }
    { "VISNO" "visibility at secondary location not available" }
    { "VR" "visual range" }
    { "VRB" "variable" }
    { "VV" "vertical visibility" }
    { "W" "west" }
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

: parse-timestamp ( report str -- report )
    metar>timestamp >>timestamp ;

: parse-wind ( report str -- report )
    dup "00000KT" = [ drop "calm" ] [
        3 cut "KT" ?tail drop [ string>number ] bi@
        [ direction>compass ] dip
        "from %s at %s knots" sprintf
    ] if '[ _ "" append-as ] change-wind ;

: parse-wind-gust ( report str -- report )
    3 cut "KT" ?tail drop "G" split1 [ string>number ] tri@
    "from %s at %s knots with gusts to %s knots" sprintf
    '[ _ "" append-as ] change-wind ;

: parse-wind-variable ( report str -- report )
    "V" split1 [ string>number ] bi@
    ", variable from %s to %s" sprintf
    '[ _ "" append-as ] change-wind ;

: parse-visibility ( report str -- miles )
    "M" ?head "less than " "" ? swap "SM" ?tail drop
    CHAR: / over index [ 1 > [ 1 cut "+" glue ] when ] when*
    string>number "%s%s statute miles" sprintf >>visibility ;

: parse-weather ( report str -- report )
    parse-abbreviations '[
        _ swap [ swap ", " glue ] unless-empty
    ] change-weather ;

: parse-sky-condition ( report str -- report )
    parse-abbreviations '[
        _ swap [ swap ", " glue ] unless-empty
    ] change-sky-condition ;

: parse-temperature ( report str -- report )
    "/" split1 "M" ?head
    [ [ string>number ] bi@ ]
    [ [ neg ] when ] bi*
    [ >>temperature ] [ >>dew-point ] bi* ;

: parse-altimeter ( report str -- report )
    "A" ?head drop string>number 100 /f >>altimeter ;

CONSTANT: re-timestamp R! \d{6}Z!
CONSTANT: re-station R! \w{4}!
CONSTANT: re-temperature R! \d{2}/[M]?\d{2}!
CONSTANT: re-wind R! \d{3}\d{2,3}KT!
CONSTANT: re-wind-gust R! \d{3}\d{2,3}G\d{2,3}KT!
CONSTANT: re-wind-variable R! \d{3}V\d{3}!
CONSTANT: re-visibility R! [M]?\d+(/\d+)?SM!
CONSTANT: re-weather R! [+-]?(VC)?(\w\w)?\w\w!
CONSTANT: re-sky-condition R! (\w{3}\d{3}(\w+)?|\w{3})!
CONSTANT: re-altimeter R! [A]\d{4}!

: parse-body ( report seq -- report )
    [
        {
            { [ dup { "METAR" "SPECI" } member? ] [ >>type ] }
            { [ dup { "AUTO" "COR" } member? ] [ >>modifier ] }
            { [ dup re-station matches? pick station>> not and ] [ >>station ] }
            { [ dup re-visibility matches? ] [ parse-visibility ] }
            { [ dup re-timestamp matches? ] [ parse-timestamp ] }
            { [ dup re-wind matches? ] [ parse-wind ] }
            { [ dup re-wind-gust matches? ] [ parse-wind-gust ] }
            { [ dup re-wind-variable matches? ] [ parse-wind-variable ] }
            { [ dup re-weather matches? ] [ parse-weather ] }
            { [ dup re-sky-condition matches? ] [ parse-sky-condition ] }
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
    "hourly pressure %s at %s millibars" sprintf ;

: parse-snow-depth ( str -- str' )
    "4/" ?head drop string>number "snow depth %s inches" sprintf ;

: parse-1hr-precipitation ( str -- str' )
    "P" ?head drop string>number 100 /f
    "hourly precipitation %.2f inches" sprintf ;

: parse-24hr-precipitation ( str -- str' )
    "7" ?head drop string>number 100 /f
    "24-hour precipitation %.2f inches" sprintf ;

: parse-peak-wind ( str -- str' )
    3 cut "/" split1 [ [ string>number ] bi@ ] dip
    dup length 2 > [ 2 cut ":" glue ] [ " past the hour" append ] if
    "from %s at %s knots occuring at %s" sprintf ;

: parse-sea-level-pressure ( str -- str' )
    "SLP" ?head drop string>number 10.0 /f 1000 +
    "sea-level pressure is %s hPa" sprintf ;

: parse-lightning ( str -- str' )
    "LTG" ?head drop 2 group [ lightning at ] map " " join ;

: parse-remarks ( report seq -- report )
    [
        {
            { [ dup R! 1\d{4}! matches? ] [ parse-6hr-max-temp ] }
            { [ dup R! 2\d{4}! matches? ] [ parse-6hr-min-temp ] }
            { [ dup R! 4\d{8}! matches? ] [ parse-24hr-temp ] }
            { [ dup R! 4/\d{3}! matches? ] [ parse-snow-depth ] }
            { [ dup R! 5\d{4}! matches? ] [ parse-1hr-pressure ] }
            { [ dup R! 7\d{4}! matches? ] [ parse-24hr-precipitation ] }
            { [ dup R! T\d{8}! matches? ] [ parse-1hr-temp ] }
            { [ dup R! \d{3}\d{2,3}/\d{2,4}! matches? ] [ parse-peak-wind ] }
            { [ dup R! P\d{4}! matches? ] [ parse-1hr-precipitation ] }
            { [ dup R! SLP\d{3}! matches? ] [ parse-sea-level-pressure ] }
            { [ dup R! LTG\w+! matches? ] [ parse-lightning ] }
            [ parse-abbreviations ]
        } cond
    ] map " " join >>remarks ;

PRIVATE>

: <report> ( str -- report )
    [ report new ] dip [ >>raw ] keep
    [ blank? ] split-when { "RMK" } split1
    [ parse-body ] [ parse-remarks ] bi* ;

<PRIVATE

: ?write ( seq -- )
    [ write ] when* ; inline

: named-row ( name quot -- )
    '[ [ _ write ] with-cell _ with-cell ] with-row ; inline

PRIVATE>

: report. ( report -- )
    [ raw>> print ] keep standard-table-style [
        {
            [ "Station" [ station>> ?write ] named-row ]
            [ "Timestamp" [ timestamp>> timestamp>rfc822 write ] named-row ]
            [ "Wind" [ wind>> ?write ] named-row ]
            [ "Visibility" [ visibility>> ?write ] named-row ]
            [ "Weather" [ weather>> ?write ] named-row ]
            [ "Sky condition" [ sky-condition>> ?write ] named-row ]
            [ "Temperature" [ temperature>> [ "%s °C" printf ] when* ] named-row ]
            [ "Dew point" [ dew-point>> [ "%s °C" printf ] when* ] named-row ]
            [ "Altimeter" [ altimeter>> [ "%.2f" printf ] when* ] named-row ]
            [ "Remarks" [ remarks>> [ 65 wrap-string print ] when* ] named-row ]
        } cleave
    ] tabular-output nl ;

! TODO: runway-visual-range
! TODO: numerical remarks:
! 60123 3 or 6 hour precipitation amount.
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


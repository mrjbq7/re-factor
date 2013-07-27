! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar calendar.format
combinators continuations csv formatting fry grouping
http.client io io.styles kernel math math.extras math.parser
memoize regexp sequences sorting.human splitting strings urls
wrap.strings ;

IN: metar

TUPLE: station cccc name state country latitude longitude ;

C: <station> station

<PRIVATE

: string>longitude ( str -- lon )
    dup R/ \d+-\d+[WE]/ matches? [
        "-" split1 unclip-last
        [ [ string>number ] bi@ 60.0 / + ]
        [ CHAR: W = [ neg ] when ] bi*
    ] [ drop f ] if ;

: string>latitude ( str -- lat )
    dup R/ \d+-\d+[NS]/ matches? [
        "-" split1 unclip-last
        [ [ string>number ] bi@ 60.0 / + ]
        [ CHAR: S = [ neg ] when ] bi*
    ] [ drop f ] if ;

PRIVATE>

MEMO: all-stations ( -- seq )
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

: find-by-cccc ( cccc -- station )
    all-stations swap '[ cccc>> _ = ] find nip ;

: find-by-country ( country -- stations )
    all-stations swap '[ country>> _ = ] filter ;

: find-by-state ( state -- stations )
    all-stations swap '[ state>> _ = ] filter ;

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

CONSTANT: weather H{
    { "BC" "patches" }
    { "BL" "blowing" }
    { "BR" "mist" }
    { "DR" "low drifting" }
    { "DS" "duststorm" }
    { "DU" "widespread dust" }
    { "DZ" "drizzle" }
    { "FC" "funnel clouds" }
    { "FG" "fog" }
    { "FU" "smoke" }
    { "FZ" "freezing" }
    { "GR" "hail" }
    { "GS" "small hail and/or snow pellets" }
    { "HZ" "haze" }
    { "IC" "ice crystals" }
    { "MI" "shallow" }
    { "PL" "ice pellets" }
    { "PO" "well-developed dust/sand whirls" }
    { "PR" "partial" }
    { "PY" "spray" }
    { "RA" "rain" }
    { "RE" "recent" }
    { "SA" "sand" }
    { "SG" "snow grains" }
    { "SH" "showers" }
    { "SN" "snow" }
    { "SQ" "squalls" }
    { "SS" "sandstorm" }
    { "TS" "thuderstorm" }
    { "UP" "unknown" }
    { "VA" "volcanic ash" }
}

CONSTANT: abbreviations H{
    { "$" "maintenance check indicator" }
    { "ACC" "altocumulus castellanus" }
    { "ACFT" "aircraft" }
    { "ACSL" "standing lenticular altocumulus" }
    { "AFT" "after" }
    { "ALP" "aircraft location point" }
    { "ALQDS" "all quadrants" } ! (Official)
    { "ALQS" "all quadrants" } ! (Unofficial)
    { "AMB" "amber" }
    { "AND" "and" }
    { "AO1" "station without a precipitation discriminator" }
    { "AO2" "station with a precipitation discriminator" }
    { "APCH" "approach" }
    { "APRNT" "apparent" }
    { "APRX" "approximately" }
    { "ASOS" "Automated Surface Observing System" }
    { "ASSOCD" "associated" }
    { "ATCT" "airport traffic control tower" }
    { "AUTO" "automated report" }
    { "B" "began" }
    { "BA" "braking action" }
    { "BECMG" "becoming" }
    { "BFR" "before" }
    { "BINOVC" "breaks in overcast" }
    { "BKN" "broken" }
    { "BLDG" "building" }
    { "BLU" "blue" }
    { "BLW" "below" }
    { "BTWN" "between" }
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
    { "CLD" "cloud" }
    { "CLDS" "clouds" }
    { "CLR" "clear sky" }
    { "CNTRL" "central" }
    { "CNTRLN" "centerline" }
    { "CONDS" "conditions" }
    { "CONS" "continuous" }
    { "CONTG" "continuing" }
    { "COR" "correction to a previously disseminated observation" }
    { "CU" "cumulus" }
    { "DATA" "data" }
    { "DEGS" "degrees" }
    { "DEPTH" "depth" }
    { "DOC" "Department of Commerce" }
    { "DOD" "Department of Defense" }
    { "DOT" "Department of Transportation" }
    { "DRY" "dry" }
    { "DSIPTG" "dissipating" }
    { "DSNT" "distant" }
    { "DVR" "dispatch visual range" }
    { "E" "east" }
    { "ENDG" "ending" }
    { "ERN" "eastern" }
    { "ESTIMATE" "estimate" }
    { "ESTMD" "estimated" }
    { "EWD" "eastward" }
    { "FAA" "Federal Aviation Administration" }
    { "FCST" "forecast" }
    { "FEW" "few" }
    { "FIBI" "filed but impracticable to transmit" }
    { "FIRST" "first observation after a break in coverage at manual station" }
    { "FM" "from" }
    { "FMH-1" "Federal Meteorological Handbook No.1, Surface Weather Observations & Reports (METAR)" }
    { "FMH2" "Federal Meteorological Handbook No.2, Surface Synoptic Codes" }
    { "FNT" "front" }
    { "FROIN" "Frost On The Indicator" }
    { "FROPA" "frontal passage" }
    { "FRQ" "frequent" }
    { "FT" "feet" }
    { "FZRANO" "freezing rain sensor not available" }
    { "GRN" "green" }
    { "HFS" "high-friction surface" }
    { "HLSTO" "hailstone" }
    { "ICAO" "International Civil Aviation Organization" }
    { "IFR" "IFR" }
    { "INCRG" "increasing" }
    { "INTMT" "intermittent" }
    { "INTO" "into" }
    { "INVOF" "in vicinity of" }
    { "IR" "ice on the runway" }
    { "ISOL" "isolated" }
    { "JTSTR" "jetstream" }
    { "KT" "knots" }
    { "L" "left" }
    { "LAST" "last observation before a break in coverage at a manual station" }
    { "LSR" "loose snow on the runway" }
    { "LST" "Local Standard Time" }
    { "LTG" "lightning" }
    { "LWR" "lower" }
    { "M" "minus, less than" }
    { "MAX" "maximum" }
    { "MEDIUM" "medium" }
    { "METAR" "aviation routine weather report" }
    { "MIN" "minimum" }
    { "MOD" "moderate" }
    { "MOV" "moved/moving/movement" }
    { "MOVD" "moved" }
    { "MOVG" "moving" }
    { "MSHP" "mishap" }
    { "MT" "mountains" }
    { "MTN" "mountain" }
    { "MVFR" "marginal VFR" }
    { "N" "north" }
    { "N/A" "not applicable" }
    { "NCD" "clear sky" }
    { "NCDC" "National Climatic Data Center" }
    { "NE" "northeast" }
    { "NO" "no" }
    { "NOS" "National Ocean Survey" }
    { "NOSIG" "no significant change is expected in next 2 hours" }
    { "NOSPECI" "no SPECI reports are taken at the station" }
    { "NOTAM" "Notice to Airmen" }
    { "NRN" "northern" }
    { "NSC" "clear sky" }
    { "NW" "northwest" }
    { "NWD" "northward" }
    { "NWS" "National Weather Service" }
    { "OBS" "observed" }
    { "OBSCD" "obscured" }
    { "OCNL" "occasional" }
    { "OFCM" "Office of the Federal Coordinator for Meteorology" }
    { "OHD" "overhead" }
    { "OPEN" "open" }
    { "OTLK" "outlook" }
    { "OVC" "overcast" }
    { "OVR" "over" }
    { "P" "greater than" }
    { "PASS" "pass" }
    { "PCPN" "precipitation" }
    { "PK" "peak" }
    { "PNHDL" "pandhandle" }
    { "PNO" "precipitation amount not available" }
    { "PRES" "Atmospheric pressure" }
    { "PRESFR" "pressure falling rapidly" }
    { "PRESRR" "pressure rising rapidly" }
    { "PROB" "probability" }
    { "PSR" "packed snow on the runway" }
    { "PWINO" "precipitation identifier sensor not available" }
    { "QTR" "quarter" }
    { "R" "right" }
    { "RCRNR" "base operations closed" }
    { "RED" "red" }
    { "ROTOR" "rotor" }
    { "RTD" "Routine Delayed (late) observation" }
    { "RV" "reportable value" }
    { "RVR" "Runway visual range" }
    { "RVRNO" "RVR system values not available" }
    { "RWY" "runway" }
    { "RY" "runway" }
    { "S" "south" }
    { "SC" "stratocumulus" }
    { "SCSL" "stratocumulus standing lenticular cloud" }
    { "SCT" "scattered" }
    { "SE" "southeast" }
    { "SEV" "severe" }
    { "SFC" "surface" }
    { "SHR" "shear" }
    { "SKC" "clear sky" }
    { "SLP" "sea-level pressure" }
    { "SLPNO" "sea-level pressure not available" }
    { "SLR" "slush on the runway" }
    { "SM" "statute miles" }
    { "SNINCR" "snow increasing rapidly" }
    { "SNOW" "snow" }
    { "SOG" "Snow on the ground" }
    { "SPECI" "an unscheduled report taken when certain criteria have been met" }
    { "SRN" "southern" }
    { "STN" "station" }
    { "SW" "southwest" }
    { "SWD" "southward" }
    { "TCU" "towering cumulus" }
    { "TEMPO" "temporary" }
    { "THLD" "threshold" }
    { "TO" "to" }
    { "TROF" "trough" }
    { "TSNO" "thunderstorm information not available" }
    { "TURB" "turbulence" }
    { "TWR" "tower" }
    { "UNKN" "unknown" }
    { "UNUSBL" "unusable" }
    { "UTC" "Coordinated Universal Time" }
    { "V" "variable" }
    { "VCNTY" "vicinity" }
    { "VFR" "VFR" }
    { "VIRGA" "virga" }
    { "VIS" "visibility" }
    { "VISNO" "visibility at secondary location not available" }
    { "VR" "visual range" }
    { "VRB" "variable" }
    { "VSBY" "visibility" }
    { "VV" "vertical visibility" }
    { "W" "west" }
    { "WG/AOS" "Working Group for Atmospheric Observing Systems" }
    { "WG/SO" "Working Group for Surface Observations" }
    { "WHT" "white" }
    { "WLY" "westerly" }
    { "WMO" "World Meteorological Organization" }
    { "WND" "wind" }
    { "WR" "wet runway" }
    { "WRM" "warm" }
    { "WRN" "western" }
    { "WS" "wind shear" }
    { "WSHFT" "wind shift" }
    { "WWD" "westward" }
    { "XTRM" "extreme" }
    { "YLO" "yellow" }
    { "Z" "zulu (i.e. Coordinated Universal Time)" }
}

: parse-abbreviations ( str -- str' )
    "/" split [
        find-numbers [
            dup number?
            [ number>string ]
            [ abbreviations ?at drop ] if
        ] map " " join
    ] map "/" join ;

: parse-timestamp ( str -- str' )
    [ now [ year>> ] [ month>> ] bi ] dip
    2 cut 2 cut 2 cut drop [ string>number ] tri@
    0 instant <timestamp> timestamp>rfc822 ;

CONSTANT: compass-directions H{
    { 0.0 "N" }
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

: parse-direction ( str -- str' )
    dup "VRB" = [ drop "variable" ] [
        string>number [ direction>compass ] keep
        "from %s (%s°)" sprintf
    ] if ;

: parse-wind ( str -- str' )
    dup "00000KT" = [ drop "calm" ] [
        3 cut "KT" ?tail drop "G" split1
        [ parse-direction ] [ string>number ] [ string>number ] tri*
        [ "%s at %s knots with gusts to %s knots" sprintf ]
        [ "%s at %s knots" sprintf ] if*
    ] if ;

: parse-wind-variable ( str -- str' )
    "V" split1 [ string>number [ direction>compass ] keep ] bi@
    ", variable from %s (%s°) to %s (%s°)" sprintf ;

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

: (parse-weather) ( str -- str' )
    dup "+FC" = [ drop "tornadoes or waterspouts" ] [
        dup first {
            { CHAR: + [ rest "heavy " ] }
            { CHAR: - [ rest "light " ] }
            [ drop f ]
        } case [
            2 group dup [ weather key? ] all?
            [ [ weather at ] map " " join ]
            [ concat parse-abbreviations ] if
        ] dip prepend
    ] if ;

: parse-weather ( str -- str' )
    "VC" over subseq? [ "VC" "" replace t ] [ f ] if
    [ (parse-weather) ]
    [ [ " in the vicinity" append ] when ] bi* ;

: parse-sky-condition ( str -- str' )
    dup abbreviations at [ nip ] [
        3 cut 3 cut
        [ abbreviations at ]
        [ string>number " at %s00 ft" sprintf ]
        [ abbreviations at [ " (%s)" sprintf ] [ f ] if* ]
        tri* 3append
    ] if* ;

: parse-temperature ( str -- temp dew-point )
    "/" split1 [
        [ f ] [
            "M" ?head [ string>number ] [ [ neg ] when ] bi*
            "%s °C" sprintf
        ] if-empty
    ] bi@ ;

: parse-altimeter ( str -- str' )
    unclip [ string>number ] [ CHAR: A = ] bi*
    [ 100 /f "%.2f Hg" sprintf ] [ "%s hPa" sprintf ] if ;

CONSTANT: re-timestamp R! \d{6}Z!
CONSTANT: re-station R! \w{4}!
CONSTANT: re-temperature R! [M]?\d{2}/([M]?\d{2})?!
CONSTANT: re-wind R! (VRB|\d{3})\d{2,3}(G\d{2,3})?KT!
CONSTANT: re-wind-variable R! \d{3}V\d{3}!
CONSTANT: re-visibility R! [M]?\d+(/\d+)?SM!
CONSTANT: re-rvr R! R\d{2}[RLC]?/\d{4}(V\d{4})?FT!
CONSTANT: re-weather R! [+-]?(VC)?(\w{2}|\w{4})!
CONSTANT: re-sky-condition R! (\w{3}\d{3}(\w+)?|\w{3}|CAVOK)!
CONSTANT: re-altimeter R! [AQ]\d{4}!

: find-one ( seq quot: ( elt -- ? ) -- seq elt/f )
    dupd find drop [ tail unclip ] [ f ] if* ; inline

: find-all ( seq quot: ( elt -- ? ) -- seq elts )
    [ find-one swap ] keep '[
        dup [ f ] [ first @ ] if-empty
    ] [ unclip ] produce rot [ prefix ] when* ; inline

: body ( report seq -- report )

    [ { "METAR" "SPECI" } member? ] find-one
    [ pick type<< ] when*

    [ re-station matches? ] find-one
    [ pick station<< ] when*

    [ re-timestamp matches? ] find-one
    [ parse-timestamp pick timestamp<< ] when*

    [ { "AUTO" "COR" } member? ] find-one
    [ pick modifier<< ] when*

    [ re-wind matches? ] find-one
    [ parse-wind pick wind<< ] when*

    [ re-wind-variable matches? ] find-one
    [ parse-wind-variable pick wind>> prepend pick wind<< ] when*

    [ re-visibility matches? ] find-one
    [ parse-visibility pick visibility<< ] when*

    [ re-rvr matches? ] find-all " " join
    [ parse-rvr ] map ", " join pick rvr<<

    [ re-weather matches? ] find-all
    [ parse-weather ] map ", " join pick weather<<

    [ re-sky-condition matches? ] find-all
    [ parse-sky-condition ] map ", " join pick sky-condition<<

    [ re-temperature matches? ] find-one
    [
        parse-temperature
        [ pick temperature<< ]
        [ pick dew-point<< ] bi*
    ] when*

    [ re-altimeter matches? ] find-one
    [ parse-altimeter pick altimeter<< ] when*

    drop ;

: signed-number ( sign value -- n )
    [ string>number ] bi@ swap zero? [ neg ] unless 10.0 / ;

: single-value ( str -- str' )
    1 cut signed-number ;

: double-value ( str -- m n )
    1 cut 3 cut [ signed-number ] dip 1 cut signed-number ;

: parse-1hr-temp ( str -- str' )
    "T" ?head drop dup length 4 > [
        double-value
        "hourly temperature %.1f and dew point %.1f" sprintf
    ] [
        single-value
        "hourly temperature %.1f" sprintf
    ] if ;

: parse-6hr-max-temp ( str -- str' )
    "1" ?head drop single-value
    "6-hourly maximum temperature %.1f" sprintf ;

: parse-6hr-min-temp ( str -- str' )
    "2" ?head drop single-value
    "6-hourly minimum temperature %.1f" sprintf ;

: parse-24hr-temp ( str -- str' )
    "4" ?head drop double-value
    "24-hour maximum temperature %.1f minimum temperature %.1f"
    sprintf ;

: parse-1hr-pressure ( str -- str' )
    "5" ?head drop 1 cut single-value [ pressure-tendency at ] dip
    "hourly pressure %s %s mb" sprintf ;

: parse-snow-depth ( str -- str' )
    "4/" ?head drop string>number "snow depth %s inches" sprintf ;

CONSTANT: low-clouds H{
    { CHAR: 1 "Cumulus (fair weather)" }
    { CHAR: 2 "Cumulus (towering)" }
    { CHAR: 3 "Cumulonimbus (no anvil)" }
    { CHAR: 4 "Stratocumulus (from Cumulus)" }
    { CHAR: 5 "Stratocumuls (not Cumulus)" }
    { CHAR: 6 "Stratus or Fractostratus (fair)" }
    { CHAR: 7 "Fractocumulus / Fractostratus (bad weather)" }
    { CHAR: 8 "Cumulus and Stratocumulus" }
    { CHAR: 9 "Cumulonimbus (thunderstorm)" }
    { CHAR: / "not valid" }
}

CONSTANT: mid-clouds H{
    { CHAR: 1 "Altostratus (thin)" }
    { CHAR: 2 "Altostratus (thick)" }
    { CHAR: 3 "Altocumulus (thin)" }
    { CHAR: 4 "Altocumulus (patchy)" }
    { CHAR: 5 "Altocumulus (thickening)" }
    { CHAR: 6 "Altocumulus (from Cumulus)" }
    { CHAR: 7 "Altocumulus (with Altocumulus, Altostratus, Nimbostratus" }
    { CHAR: 8 "Altocumulus (with turrets)" }
    { CHAR: 9 "Altocumulus (chaotic)" }
    { CHAR: / "above overcast" }
}

CONSTANT: high-clouds H{
    { CHAR: 1 "Cirrus (filaments)" }
    { CHAR: 2 "Cirrus (dense)" }
    { CHAR: 3 "Cirrus (often with Cumulonimbus)" }
    { CHAR: 4 "Cirrus (thickening)" }
    { CHAR: 5 "Cirrus / Cirrostratus (low in sky)" }
    { CHAR: 6 "Cirrus / Cirrostratus (hi in sky)" }
    { CHAR: 7 "Cirrostratus (entire sky)" }
    { CHAR: 8 "Cirrostratus (partial)" }
    { CHAR: 9 "Cirrocumulus or Cirrocumulus / Cirrus / Cirrostratus" }
    { CHAR: / "above overcast" }
}

: parse-cloud-cover ( str -- str' )
    "8/" ?head drop first3 [
        dup CHAR: 0 = [ drop f ] [
            low-clouds at "low clouds are %s" sprintf
        ] if
    ] [
        dup CHAR: 0 = [ drop f ] [
            mid-clouds at "mid clouds are %s" sprintf
        ] if
    ] [
        dup CHAR: 0 = [ drop f ] [
            high-clouds at "high clouds are %s" sprintf
        ] if
    ] tri* 3array " " join ;

: parse-inches ( str -- str' )
    dup [ CHAR: / = ] all? [ drop "unknown" ] [
        string>number
        [ "trace" ] [ 100 /f "%.2f inches" sprintf ] if-zero
    ] if ;

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

CONSTANT: re-recent-weather R! ((\w{2})?[BE]\d{2,4}((\w{2})?[BE]\d{2,4})?)+!
CONSTANT: re-began/ended R! [BE]\d{2,4}!

: parse-began/ended ( str -- str' )
    unclip swap
    [ CHAR: B = "began" "ended" ? ]
    [ parse-recent-time ] bi* "%s at %s" sprintf ;

: split-recent-weather ( str -- seq )
    [ dup empty? not ] [
        dup [ digit? ] find drop
        over [ digit? not ] find-from drop
        [ cut ] [ f ] if* swap
    ] produce nip ;

: (parse-recent-weather) ( str -- str' )
    dup [ digit? ] find drop 2 > [
        2 cut [ weather at " " append ] dip
    ] [ f swap ] if parse-began/ended "" append-as ;

: parse-recent-weather ( str -- str' )
    split-recent-weather
    [ (parse-recent-weather) ] map " " join ;

: parse-varying ( str -- str' )
    "V" split1 [ string>number ] bi@
    "varying between %s00 and %s00 ft" sprintf ;

: parse-from-to ( str -- str' )
    "-" split1 [ parse-abbreviations ] bi@ " to " glue ;

: parse-water-equivalent-snow ( str -- str' )
    "933" ?head drop parse-inches
    "%s water equivalent of snow on ground" sprintf ;

: parse-duration-of-sunshine ( str -- str' )
    "98" ?head drop string>number
    [ "no" ] [ "%s minutes of" sprintf ] if-zero
    "%s sunshine" sprintf ;

: remarks ( report seq -- report )
    [
        {
            { [ dup R! 1\d{4}! matches? ] [ parse-6hr-max-temp ] }
            { [ dup R! 2\d{4}! matches? ] [ parse-6hr-min-temp ] }
            { [ dup R! 4\d{8}! matches? ] [ parse-24hr-temp ] }
            { [ dup R! 4/\d{3}! matches? ] [ parse-snow-depth ] }
            { [ dup R! 5\d{4}! matches? ] [ parse-1hr-pressure ] }
            { [ dup R! 6[\d/]{4}! matches? ] [ parse-6hr-precipitation ] }
            { [ dup R! 7\d{4}! matches? ] [ parse-24hr-precipitation ] }
            { [ dup R! 8/\d{3}! matches? ] [ parse-cloud-cover ] }
            { [ dup R! 933\d{3}! matches? ] [ parse-water-equivalent-snow ] }
            { [ dup R! 98\d{3}! matches? ] [ parse-duration-of-sunshine ] }
            { [ dup R! T\d{4,8}! matches? ] [ parse-1hr-temp ] }
            { [ dup R! \d{3}\d{2,3}/\d{2,4}! matches? ] [ parse-peak-wind ] }
            { [ dup R! P\d{4}! matches? ] [ parse-1hr-precipitation ] }
            { [ dup R! SLP\d{3}! matches? ] [ parse-sea-level-pressure ] }
            { [ dup R! LTG\w+! matches? ] [ parse-lightning ] }
            { [ dup R! \d{3}V\d{3}! matches? ] [ parse-varying ] }
            { [ dup R! [^-]+-[^-]+! matches? ] [ parse-from-to ] }
            { [ dup R! \d+.\d+! matches? ] [ ] }
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
    [ body ] [ remarks ] bi* ;

: row. ( name quot -- )
    '[
        [ _ write ] with-cell
        [ @ [ 65 wrap-string write ] when* ] with-cell
    ] with-row ; inline

: report. ( report -- )
    standard-table-style [
        {
            [ "Station" [ station>> ] row. ]
            [ "Timestamp" [ timestamp>> ] row. ]
            [ "Wind" [ wind>> ] row. ]
            [ "Visibility" [ visibility>> ] row. ]
            [ "RVR" [ rvr>> ] row. ]
            [ "Weather" [ weather>> ] row. ]
            [ "Sky condition" [ sky-condition>> ] row. ]
            [ "Temperature" [ temperature>> ] row. ]
            [ "Dew point" [ dew-point>> ] row. ]
            [ "Altimeter" [ altimeter>> ] row. ]
            [ "Remarks" [ remarks>> ] row. ]
            [ "Raw Text" [ raw>> ] row. ]
        } cleave
    ] tabular-output nl ;

PRIVATE>

GENERIC: metar ( station -- metar )

M: station metar cccc>> metar ;

M: string metar
    "http://weather.noaa.gov/pub/data/observations/metar/stations/%s.TXT"
    sprintf http-get nip ;

GENERIC: metar. ( station -- )

M: station metar. cccc>> metar. ;

M: string metar.
    [ metar <report> report. ]
    [ drop "%s METAR not found\n" printf ] recover ;

! TODO: numerical remarks:
! RH/41
! 931222 Snowfall in the last 6-hours.
! 933021 Liquid water equivalent of the snow (SWE).

! TODO: calculate wind chill?
! http://en.wikipedia.org/wiki/Wind_chill
!   if (self.temp and self.temp <= 10 and
!      self.windspeed and (self.windspeed*3.6) > 4.8):
!      self.w_chill = (13.12 + 0.6215*self.temp -
!                      11.37*(self.windspeed*3.6)**0.16 +
!                      0.3965*self.temp*(self.windspeed*3.6)**0.16)


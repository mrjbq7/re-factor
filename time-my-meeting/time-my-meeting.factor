! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs calendar calendar.format colors
formatting io kernel layouts literals math math.functions
sequences strings threads timers ui ui.baseline-alignment
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labeled ui.gadgets.labels ui.gadgets.tracks
ui.pens.solid ;

IN: time-my-meeting

CONSTANT: THINGS-THAT-TAKE-TIME {
    ! <10 seconds
    { "A single frame of a film" 100 }
    { "It would take light to go around the Earth" 133 }
    { "A blink of an eye" 400 }
    { "The time it takes light to reach Earth from the moon" 1255 }
    { "The fastest Formula 1 pit stop" 1820 }
    { "The fastest 1/4 mile drag race time" 3580 }
    { "The fastest Rubik's cube solve" 4221 }
    { "The fastest 40-yard time at the NFL Combine" 4240 }
    { "The fastest 1 liter beer chug" 4370 }
    { "A skippable Youtube ad" 5000 }
    { "A full bull ride" 8000 }
    { "The fastest 100m sprint" 9580 }

    ! 10 Seconds
    { "The Wright Brothers first flight" 12000 }
    { "The fastest 200m sprint" 19190 }
    { "The fastest 50m freestyle swim lap" 21300 }
    { "The Westminster Kennel Club dog agility record" 28440 }
    { "A typical television ad" 30000 }
    { "The fastest NASCAR lap at Daytona" 40364 }
    { "The fastest 400m sprint" 43030 }
    { "The fastest NASCAR lap at Talladega" 44270 }
    { "The fastest 100m freestyle swim lap" 47050 }

    ! 1 Minute
    { "\"Just a minute\"" 60000 }
    { "The fastest Formula 1 lap at Monaco" 74260 }
    { "The fastest Formula 1 lap at Monza" 81046 }
    { "The fastest 800m sprint" 100910 }
    { "The fastest 200m freestyle swim lap" 102960 }
    { "The fastest Kentucky Derby time" 119400 }
    { "An NHL penalty box time for slashing, tripping, or holding" 120000 }
    { "How long it takes to drive across the Golden Gate Bridge (without traffic)" 135000 }
    { "The duration of the \"Millenium Force\" roller coaster" 140000 }
    { "The longest Super Bowl national anthem" 156000 }
    { "One round of a boxing match" 180000 }
    { "The average song length on Spotify" 183000 }
    { "The fastest 1,500m run" 206000 }
    { "The song \"Never Gonna Give You Up\" by Rick Astley" 215000 }
    { "The fastest 400m freestyle swim lap" 220140 }
    { "The fastest 1 mile run" 223130 }
    { "The duration of the \"Steel Dragon\" roller coaster" 240000 }
    { "The duration of \"The Beast\" roller coaster" 250000 }
    { "The song \"4:33\" by John Cage" 273000 }
    { "The longest sky diving freefall" 276000 }
    { "The Any% speedrun of Super Mario Bros for NES" 294948 }

    ! 5 Minutes
    { "An NHL penalty box time for fighting" 300000 }
    { "The average duration of a typical sky dive" 330000 }
    { "The average time for a drive-thru order" 356800 }
    { "The time it takes Jeff Bezos to make $1 million" 402000 }
    { "The fastest race car lap around the Nurburgring" 403300 }
    { "The time it takes light to reach Earth from the sun" 500000 }
    { "The time it takes a rocket ship to reach outer space" 510000 }
    { "A typical marching band show" 515000 }

    ! 10 Minutes
    { "The length of the first space walk" 600000 }
    { "The longest a human has held their breath (non-oxygen assisted)" 695000 }
    { "The average duration of popular Youtube videos" 702000 }
    { "The time it takes an average human to walk 1km" 710000 }
    { "The fastest 5K run" 757350 }
    { "The average time to bake a pizza" 810000 }
    { "1% of the entire day" 864000 }

    ! 15 Minutes
    { "A typical commute in the United States" 960000 }
    { "The fastest superbike lap of the Isle of Man TT" 1002778 }
    { "MLK's \"I Have A Dream\" Speech" 1020000 }
    { "An average baseball inning" 1200000 }
    { "The song \"2112\" by Rush" 1233000 }
    { "The first angels to appear in the movie \"Angels in the Outfield\" (1994)" 1275000 }
    { "An episode of The Office, Seinfeld, or Rick &amp; Morty" 1320000 }
    { "The time it takes to drive the entire Chesapeake Bay Bridge Tunnel" 1380000 }
    { "The song \"Octavarium\" by Dream Theater" 1440000 }
    { "A typical Super Bowl halftime show" 1500000 }
    { "The fastest 10K run" 1584000 }
    { "It takes for Bobby Boucher to get his first game snap in the movie \"The Waterboy\" (1998)" 1719000 }

    ! 30 Minutes
    { "The average time to bake a cake" 1950000 }
    { "The time it takes until the launch in the movie Apollo 13 (1995)" 2081000 }
    { "It takes WALL-E to arrive at the Axiom in the movie \"WALL-E\" (2008)" 2164000 }
    { "The shortest war in history (Anglo-Zanzibar War)" 2280000 }
    { "It takes Harry Potter to arrive at Hogwarts in \"Harry Potter and the Sorcerer's Stone\" (2001)" 2381000 }
    { "The album \"Thriller\" by Michael Jackson" 2539000 }
    { "The album \"Dark Side of the Moon\" by Pink Floyd" 2589000 }
    { "An episode of Breaking Bad, House, or Firefly" 2640000 }
    { "The boot camp sequence in the movie \"Full Metal Jacket\" (1987)" 2730000 }
    { "The album \"Abbey Road\" by The Beatles" 2823000 }
    { "It takes Simba to become an adult in the movie \"The Lion King\" (1994)" 2849000 }
    { "10% of a typical work day in the United States" 2880000 }
    { "The album \"Kid A\" by Radiohead" 2996000 }
    { "The time limit for the essay portion of the SATs" 3000000 }
    { "The time it takes a standard ice cube to melt at room temperature" 3150000 }
    { "0.01% of an entire year" 3155692 }
    { "The album \"Fearless\" by Taylor Swift" 3221000 }
    { "The time it takes for the basketball game to start in the movie \"Space Jam\"" 3222000 }
    { "An episode of Game of Thrones, True Detective, or The Sopranos" 3300000 }
    { "It takes Harry and Lloyd arrive in Aspen in the movie \"Dumb and Dumber\" (1994)" 3394000 }
    { "The album \"Jagged Little Pill\" by Alanis Morissette" 3443000 }
    { "The fastest half-marathon" 3451000 }

    ! 1 Hour
    { "An episode of Top Gear" 3600000 }
    { "The inception of Robert Fischer begins in the movie \"Inception\" (2010)" 3847000 }
    { "Riding the longest subway line in NYC from Queens to Inwood" 3900000 }
    { "The time it takes Jeff Bezos to make $10 million" 4017600 }
    { "It takes before Sean Connery says \"Welcome to the Rock\" in the movie \"The Rock\" (1996)" 4022000 }
    { "A flight from Syracuse to New York City" 4140000 }
    { "5% of the entire day" 4320000 }
    { "The album \"Goodbye Yellow Brick Road\" by Elton John" 4580000 }
    { "The album \"Scenes From A Memory\" by Dream Theater" 4626000 }
    { "The movie \"Primer\" (2004)" 4740000 }
    { "It takes to fully charge a Tesla (at 440V)" 4788000 }
    { "The ferry duration from Long Island, NY to  New London, CT" 4800000 }
    { "The movie \"Toy Story\" (1995)" 4860000 }
    { "A drive from Syracuse, NY to Rochester, NY (87.5 miles)" 4920000 }
    { "The movie \"The Lion King\" (1994)" 5280000 }
    { "The longest State of the Union address" 5280000 } ! Duplicate time...

    ! 1.5 Hours
    { "The movie \"Mony Python and the Holy Grail\" (1975)" 5460000 }
    { "The movie \"Monsters, Inc.\" (2001)" 5520000 }
    { "An average duration of a soccer game" 5700000 }
    { "The movie \"Reservoir Dogs\" (1992)" 5940000 }
    { "The longest Innaugural address" 6300000 }
    { "A drive from Orlando, FL to Tampa, FL (84.6 miles)" 6660000 }
    { "An SR-71 flight from New York City to London" 6896400 }
    { "The movie \"Alien\" (1979)" 7020000 }

    ! 2 Hours
    ! "25% of a typical work day in the United States" 7200000 }
    { "The average duration of an NCAA basketball game" 7200000 }
    { "The movie \"Star Wars: A New Hope\" (1977)" 7260000 }
    { "The fastest marathon time ever ran" 7299000 }
    { "The time it takes to listen to every studio album by Nirvana" 7667000 }
    { "The movie \"Dogma\" (1999)" 7680000 }
    { "The average duration of an NBA basketball game" 7860000 }
    { "The movie \"The Matrix\" (1999)" 8160000 }
    { "The movie \"Fight Club\" (1999)" 8340000 }
    { "The movie \"The Shawshank Redemption\" (1994)" 8520000 }
    { "The movie \"Forrest Gump\" (1994)" 8520000 }
    { "A drive from New York City to Philadelphia (94.6 miles)" 8520000 }
    { "10% of the entire day" 8640000 }
    { "The movie \"Inception\" (2010)" 8880000 }
    { "The movie \"Avengers: Infinity War\" (2018)" 8940000 }
    { "The movie \"Pulp Fiction\" (1994)" 9240000 }
    { "It takes Voyager 1 to travel 100,000 miles" 9360000 }
    { "The movie \"Avatar\" (2009)" 9720000 }
    { "The average duration of an NHL hockey game" 9750000 }
    { "The movie \"Saving Private Ryan\" (1998)" 10140000 }
    { "The movie \"The Godfather\" (1972)" 10500000 }
    { "The movie \"Lord of the Rings: The Fellowship of the Ring\" (2001)" 10680000 }

    ! 3 Hours
    { "The average duration of an NFL football game" 10800000 }
    { "The total time limit of the SATs" 10800000 }
    { "The movie \"Avengers: Endgame\" (2019)" 10860000 }
    { "The average duration of an MLB baseball game" 11280000 }
    { "The time it takes for a standard ice cube to freeze in a freezer" 11700000 }
    { "The movie \"Titanic\" (1997)" 12600000 }
    { "A drive from Boston to New York City (215.9 miles)" 13560000 }
    { "Alex Honnold's free solo climb of El Capitan" 14160000 }

    ! 4 Hours
    { "Half of a typical work day in the United States" 14400000 }
    { "The flight time from New York City to Los Angeles" 19800000 }
    { "The time limit of one session of the Bar exam" 21600000 }
    { "It takes Voyager 1 to travel 250,000 miles" 23400000 }
    { "The fastest swimmer to cross the English Channel" 24900000 }

    ! >8 Hours
    { "A full typical work day in the United States" 28800000 }
    { "0.1% of an entire year" 31536000 }
    { "The time it takes Jeff Bezos to make $100 million" 40173000 }
    { "The time it takes to assemble a car" 57600000 }
    { "1% of an entire year" 315360000 }
    { "It takes for the Lōʻihi volcano to rise above the surface of the ocean becoming a new Hawaiian island" $ most-positive-fixnum } ! 18,267,314 years
}

: human-time ( milliseconds -- string )
    1000 /f dup 60 <
    [ "%.1f seconds" sprintf ]
    [ round >integer seconds duration>human-readable ] if ;

: time-my-meeting. ( -- )
    now THINGS-THAT-TAKE-TIME [
        [ milliseconds pick time+ sleep-until ]
        [ human-time "%s (%s)\n" printf flush ] bi
    ] assoc-each drop ;

: next-thing-that-takes-time ( elapsed-millis -- i )
    THINGS-THAT-TAKE-TIME [ second < ] with find drop ;

TUPLE: meeting-gadget < track timer current total start ;

: large-theme ( gadget -- gadget )
    [ clone 18 >>size ] change-font ;

: gray-theme ( gadget -- gadget )
    [ clone 14 >>size COLOR: gray >>foreground ] change-font ;

: button-theme ( gadget -- gadget )
    [ clone 16 >>size t >>bold? ] change-font ;

:: <meeting-gadget> ( -- gadget )
    vertical meeting-gadget new-track dup :> meeting
        { 0 5 } >>gap
        COLOR: #f7f08b <solid> >>interior
        0 >>total

        100 CHAR: space <string> :> spaces

        spaces <label> large-theme :> current-text
        spaces <label> gray-theme  :> current-time

        spaces <label> large-theme :> total-time
        spaces <label> gray-theme  :> start-time

        spaces <label> large-theme :> next-text
        spaces <label> gray-theme  :> next-time

        [
            meeting total>>
            meeting [ now dup ] change-start drop swap time- duration>milliseconds +
            dup meeting total<<
            dup next-thing-that-takes-time

            [
                [
                    1 - THINGS-THAT-TAKE-TIME nth first2
                    [ current-text string<< ]
                    [ human-time current-time string<< ] bi*
                ] unless-zero
            ] [
                THINGS-THAT-TAKE-TIME nth first2
                [ next-text string<< ]
                [ human-time next-time string<< ] bi*
            ] bi

            human-time total-time string<<

            total-time relayout
        ] f 100 milliseconds <timer> >>timer

        vertical <track> { 5 5 } >>gap
            current-text large-theme f track-add
            current-time gray-theme f track-add
            { 5 5 } <border> { 1 1 } >>fill
        "This meeting is longer than..." <labeled-gadget> f track-add

        vertical <track> { 5 5 } >>gap
            total-time large-theme f track-add
            start-time gray-theme f track-add
            { 5 5 } <border> { 1 1 } >>fill
        "It has been going on for..." <labeled-gadget> f track-add

        vertical <track> { 5 5 } >>gap
            next-text large-theme f track-add
            next-time gray-theme f track-add
            { 5 5 } <border> { 1 1 } >>fill
        "The next milestone is..." <labeled-gadget> f track-add

        "Start" <label> button-theme :> start-label
        "Reset" <label> button-theme :> reset-label

        horizontal <track>
            +baseline+ >>align
            { 5 5 } >>gap
            start-label [
                meeting
                dup start>> [
                    0 >>total now timestamp>hms
                    "Started at " prepend start-time string<<
                ] unless
                now >>start
                timer>> dup thread>>
                [ stop-timer "Resume" start-label string<< ]
                [ start-timer "Pause" start-label string<< ] if
                relayout
            ] <border-button> f track-add

            reset-label [
                drop
                meeting 0 >>total f >>start timer>> stop-timer
                "Start" start-label string<<
                "" current-text string<<
                "" current-time string<<
                "" total-time string<<
                "" start-time string<<
                "" next-text string<<
                "" next-time string<<
            ] <border-button> f track-add
        { 5 5 } <border> f track-add
;

MAIN-WINDOW: time-my-meeting
    { { title "Time My Meeting" } }
    <meeting-gadget> >>gadgets ;

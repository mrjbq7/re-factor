USING: arrays assocs kernel literals make math multiline
sequences splitting ;

IN: keyboard

<<
CONSTANT: qwerty-layout [=[
`~ 1! 2@ 3# 4$ 5% 6^ 7& 8* 9( 0) -_ =+
    qQ wW eE rR tT yY uU iI oO pP [{ ]} \|
     aA sS dD fF gG hH jJ kK lL ;: '"
      zZ xX cC vV bB nN mM ,< .> /?
]=]

CONSTANT: dvorak-layout [=[
`~ 1! 2@ 3# 4$ 5% 6^ 7& 8* 9( 0) [{ ]}
    '" ,< .> pP yY fF gG cC rR lL /? =+ \|
     aA oO eE uU iI dD hH tT nN sS -_
      ;: qQ jJ kK xX bB mM wW vV zZ
]=]

CONSTANT: keypad-layout [=[
  / * -
7 8 9 +
4 5 6
1 2 3
  0 .
]=]

CONSTANT: mac-keypad-layout [=[
  = / *
7 8 9 -
4 5 6 +
1 2 3
  0 .
]=]

:: slanted-adjacency ( x y -- seq )
    { { -1 0 } { 0 -1 } { 1 -1 } { 1 0 } { 0 1 } { -1 1 } }
    [ first2 [ x + ] [ y + ] bi* 2array ] map ;

:: aligned-adjacency ( x y -- seq )
    { { -1 0 } { -1 -1 } { 0 -1 } { 1 -1 } { 1 0 } { 1 1 } { 0 1 } { -1 1 } }
    [ first2 [ x + ] [ y + ] bi* 2array ] map ;

:: build-position-table ( layout slanted? -- positions )
    [
        layout "\n " split harvest :> tokens
        tokens first length dup 1 + :> ( n x )
        tokens [ length n assert= ] each
        layout "\n" split [| line y |
            slanted? y 1 - 0 ? :> slant
            line " " split harvest [| token |
                line token subseq-index slant - x /mod 0 assert=
                y 2array token swap ,,
            ] each
        ] each-index
    ] H{ } make ;

:: build-adjacency-graph ( layout slanted? -- adjacency )
    [
        layout slanted? build-position-table :> positions
        positions [
            [
                first2 slanted?
                [ slanted-adjacency ] [ aligned-adjacency ] if
                [ positions at ] map
            ] dip [ ,, ] with each
        ] assoc-each
    ] H{ } make ;
>>

! Keyboard adjacency graphs for spatial pattern matching
! Each key maps to an array of adjacent keys in clockwise order
! from the left. For example, on QWERTY it will be the keys
! [left, upper-left, upper-right, right, lower-right, lower-left]

<<
CONSTANT: qwerty-graph $[ qwerty-layout t build-adjacency-graph ]

CONSTANT: dvorak-graph $[ dvorak-layout t build-adjacency-graph ]

CONSTANT: keypad-graph $[ keypad-layout f build-adjacency-graph ]

CONSTANT: mac-keypad-graph $[ mac-keypad-layout f build-adjacency-graph ]
>>

<<
: calc-average-degree ( graph -- avg )
    [ values [ sift length ] map-sum ] [ assoc-size ] bi / ;
>>

CONSTANT: qwerty-avg-degree $[ qwerty-graph calc-average-degree ]

CONSTANT: dvorak-avg-degree $[ qwerty-graph calc-average-degree ]

CONSTANT: keypad-avg-degree $[ keypad-graph calc-average-degree ]

CONSTANT: mac-keypad-avg-degree $[ mac-keypad-graph calc-average-degree ]

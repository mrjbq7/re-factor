! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators kernel math sequences fry ;

IN: bowling

TUPLE: game frame# throw# score pins bonus ;

: <game> ( -- game ) 0 0 0 10 0 game boa ;

ERROR: invalid-throw game ;

<PRIVATE

: next-frame ( game -- game )
    dup frame#>> 9 < [
        [ 1 + ] change-frame#
    ] when 0 >>throw# 10 >>pins ;

: check-throw# ( game n -- game )
    over throw#>> = [ invalid-throw ] unless ;

: check-pins ( game n -- game n )
    over pins>> dupd <= [ invalid-throw ] unless ;

: apply-bonus ( game n -- game n' )
    over bonus>> [
        2 > [
            [ [ 2 - ] change-bonus ] dip 3 *
        ] [
            [ [ 1 - ] change-bonus ] dip 2 *
        ] if
    ] unless-zero ;

: take-pins ( game n -- game )
    check-pins
    [ '[ _ - ] change-pins ]
    [ apply-bonus '[ _ + ] change-score ]
    bi ;

: take-all-pins ( game -- game )
    dup pins>> take-pins ;

: add-bonus ( game n -- game )
    over frame#>> 9 < [ '[ _ + ] change-bonus ] [ drop ] if ;

: strike ( game -- game )
    0 check-throw# 10 take-pins 2 add-bonus next-frame ;

: spare ( game -- game )
    1 check-throw# take-all-pins 1 add-bonus next-frame ;

: hit ( game n -- game )
    take-pins dup throw#>> zero?
    [ 1 >>throw# ] [ next-frame ] if ;

: throw-ball ( game ch -- game )
    {
        { CHAR: - [ 0 hit ] }
        { CHAR: X [ strike ] }
        { CHAR: / [ spare ] }
        [ CHAR: 0 - hit ]
    } case ;

PRIVATE>

: score-frame ( str -- score )
    [ <game> ] dip [ throw-ball ] each
    [ frame#>> 1 assert= ] [ score>> ] bi ;

: score-game ( str -- score )
    [ <game> ] dip [ throw-ball ] each
    [ frame#>> 9 assert= ] [ score>> ] bi ;

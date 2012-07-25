! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators kernel math sequences ;

IN: bowling

TUPLE: game frame# throw# score pins bonus ;

: <game> ( -- game ) 0 0 0 10 0 game boa ;

ERROR: invalid-throw ;

<PRIVATE

: next-frame ( game -- game )
    dup frame#>> 9 < [
        [ 1 + ] change-frame# 0 >>throw# 10 >>pins
    ] [ [ 1 + ] change-throw# 10 >>pins ] if ;

: next-throw ( game -- game )
    dup throw#>> zero?
    [ [ 1 + ] change-throw# ] [ next-frame ] if ;

: check-throw# ( game n -- game )
    over frame#>> 9 < [
        over throw#>> = [ invalid-throw ] unless
    ] [ drop ] if ;

: check-pins ( game n -- game n )
    over pins>> dupd <= [ invalid-throw ] unless ;

: bonus ( game n -- game n' )
    over bonus>> [
        2 >
        [ [ [ 2 - ] change-bonus ] dip 3 * ]
        [ [ [ 1 - ] change-bonus ] dip 2 * ]
        if
    ] unless-zero ;

: take-pins ( game n -- game )
    check-pins
    [ '[ _ - ] change-pins ]
    [ bonus '[ _ + ] change-score ]
    bi ;

: add-bonus ( game n -- game )
    over frame#>> 9 < [
        '[ _ + ] change-bonus
    ] [ drop ] if ;

: strike ( game -- game )
    0 check-throw# 10 take-pins
    2 add-bonus next-frame ;

: spare ( game -- game )
    1 check-throw# dup pins>> take-pins
    1 add-bonus next-frame ;

: hit ( game n -- game )
    take-pins next-throw ;

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

! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ;
IN: elo

: elo-expected ( rating opponent -- expected )
    swap - 400.0 / 10^ 1 + recip ;

:: elo ( rating-a rating-b score k -- rating-a' rating-b' )
    score rating-a rating-b elo-expected - k * :> change
    rating-a change + rating-b change - ;

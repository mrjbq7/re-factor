USING: help.markup help.syntax math ;
IN: elo

HELP: elo-expected
{ $values { "rating" real } { "opponent" real } { "expected" real } }
{ $description "Computes the first player's expected score using the logistic Elo formula with a 400-point scale. Equal ratings give 0.5. Inputs are finite ratings; the result is floating point. With draws possible, expected score is the probability of winning plus half the probability of drawing." } ;

HELP: elo
{ $values
    { "rating-a" real } { "rating-b" real } { "score" real } { "k" real }
    { "rating-a'" real } { "rating-b'" real }
}
{ $description "Updates both ratings after one game. The score is from player A's perspective: 1 for a win, 0.5 for a draw, and 0 for a loss. Both players use the same K-factor. The change is computed from the original ratings, then added to A and subtracted from B." }
{ $notes "Pass finite ratings, a score from 0 through 1, and a finite nonnegative K-factor. These are caller preconditions, not checked by the word. Results are not rounded. Rating totals are conserved up to floating-point rounding. Initial ratings and K are chosen by the caller; there is no stored player state." }
{ $examples
    { $example "USING: arrays elo prettyprint ;" "1500 1500 1 32 elo 2array ." "{ 1516.0 1484.0 }" }
} ;

ARTICLE: "elo" "Elo ratings"
"Two words implement a simple, per-game Elo model with a shared K-factor:"
{ $subsections elo-expected elo }
"This vocabulary implements the basic logistic model, without federation-specific rating rules." ;

ABOUT: "elo"

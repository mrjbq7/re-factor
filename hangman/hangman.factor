USING: combinators.short-circuit io io.encodings.utf8 io.files
kernel make math multiline namespaces random sequences
sequences.interleaved sets sorting unicode ;

IN: hangman

SYMBOL: target-word
SYMBOL: guesses

CONSTANT: HANGED-MAN {
[[
      ┌───┐
      │   │
          │
          │
          │
          │
          │
          │
          │
          │
   └──────┘
]] [[
      ┌───┐
      │   │
      O   │
          │
          │
          │
          │
          │
          │
          │
   └──────┘
]] [[
      ┌───┐
      │   │
      O   │
     ─┼─  │
      │   │
      │   │
          │
          │
          │
          │
   └──────┘
]] [[
      ┌───┐
      │   │
      O   │
     ─┼─  │
    / │   │
      │   │
          │
          │
          │
          │
   └──────┘
]] [[
      ┌───┐
      │   │
      O   │
     ─┼─  │
    / │ \ │
      │   │
          │
          │
          │
          │
   └──────┘
]] [[
      ┌───┐
      │   │
      O   │
     ─┼─  │
    / │ \ │
      │   │
     ─┴─  │
    /     │
    │     │
          │
   └──────┘
]] [[
      ┌───┐
      │   │
      O   │
     ─┼─  │
    / │ \ │
      │   │
     ─┴─  │
    /   \ │
    │   │ │
          │
   └──────┘
]]
}

: #wrong-guesses ( -- n )
    guesses get target-word get diff cardinality ;

: hanged-man. ( -- )
    #wrong-guesses HANGED-MAN nth print ;

: random-word ( -- word )
    "vocab:hangman/words.txt" utf8 file-lines random ;

: valid-guess? ( input -- ? )
    {
        [ length 1 = ]
        [ lower? ]
        [ first guesses get ?adjoin ]
    } 1&& ;

: player-guess ( -- ch )
    f [ dup valid-guess? ] [ drop readln ] do until first ;

: spaces ( str -- str' )
    CHAR: \s <interleaved> ;

: guessed-letters ( -- str )
    guesses get members sort spaces ;

: lose? ( -- ? )
    #wrong-guesses HANGED-MAN length 1 - >= ;

: win? ( -- ? )
    target-word get guesses get diff null? ;

: game-over? ( -- ? )
    { [ win? ] [ lose? ] } 0|| ;

: guessed-word ( -- str )
    target-word get guesses get '[
        dup _ in? [ drop CHAR: _ ] unless
    ] map spaces ;

: with-hangman ( quot -- )
    [
        random-word target-word ,,
        HS{ } clone guesses ,,
    ] H{ } make swap with-variables ; inline

: play-hangman ( -- )
    [
        "Welcome to Hangman!" print

        [ game-over? ] [
            hanged-man.
            "Your word is: " write guessed-word print
            "Your guesses: " write guessed-letters print

            nl "What is your guess? " write flush

            player-guess target-word get in?
            "Great guess!" "Sorry, it's not there." ? print
        ] until

        hanged-man.
        lose? "Congrats! You did it!" "Sorry, you lost!" ? print
        "Your word was: " write target-word get print
    ] with-hangman ;

MAIN: play-hangman

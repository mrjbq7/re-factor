
USING: combinators.random formatting generalizations random ;

IN: insults

! http://was.fm/linguistics/generating_insults

CONSTANT: animals {
    "chicken" "cow" "dog" "donkey" "duck" "goat" "goose" "horse"
    "pig" "sheep" "turkey" "fish" "rat" "monkey"
}

CONSTANT: bodyparts {
    "face" "ass" "brain" "cunt"
}

CONSTANT: obscene {
    "shit" "cum" "piss"
}

CONSTANT: character {
    "arrogant" "obnoxious" "surly" "sarcastic" "ignorant"
    "guilible" "confused" "immature" "insipid" "stubborn"
    "spiteful" "insensitive" "prejudiced" "spoilt"
}

CONSTANT: imperatives {
    "go eat" "go drink" "go lick" "go suck"
}

: insult ( -- str )
    imperatives obscene character {
        [ animals bodyparts ]
        [ bodyparts obscene ]
        [ obscene animals ]
    } call-random [ random ] 5 napply
    "%s %s you %s %s%s!" sprintf ;

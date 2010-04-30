
USING: kernel tools.test wordgen ;

IN: wordgen.tests

[
    H{
        { "great" H{ { "you" 1 } } }
        { "it's" H{ { "great" 1 } } }
        { "you" H{ { "know" 2 } } }
        { "know" H{ { "it's" 1 } { "you" 1 } } }
    }
]
[
    H{ } clone "you know it's great you know"
    word-list word-frequency
] unit-test


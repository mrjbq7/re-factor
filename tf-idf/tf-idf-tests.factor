USING: tf-idf tools.test ;

{
    H{
        { "a" { "path1" 3 } }
        { "b" { "path1" 2 } }
        { "c" { "path1" 1 } }
    }
} [ "path1" { "a" "a" "a" "b" "b" "c" } index1 ] unit-test

{
    H{
        { "a" V{ { "path1" 3 } { "path2" 1 } } }
        { "b" V{ { "path1" 2 } { "path2" 2 } } }
        { "c" V{ { "path1" 1 } { "path2" 1 } } }
        { "d" V{ { "path2" 1 } } }
    }
} [
    {
        { "path1" { "a" "a" "a" "b" "b" "c" } }
        { "path2" { "a" "b" "b" "c" "d" } }
    } index-all
] unit-test

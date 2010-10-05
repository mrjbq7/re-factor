
USING: assocs fry kernel sequences ternary-search-trees
tools.test ;

IN: ternary-search-trees

[ 0 ] [ <ternary-search-tree> assoc-size ] unit-test
[ 1 ] [
    "value" "key" <ternary-search-tree>
    [ set-at ] [ assoc-size ] bi
] unit-test
[ 1 ] [
    "value" "key" "value" "key" <ternary-search-tree>
    [ set-at ] [ set-at ] [ assoc-size ] tri
] unit-test


[ "value" 1 ] [
    "value" "key" <ternary-search-tree>
    [ [ set-at ] [ at ] 2bi ] [ assoc-size ] bi
] unit-test

[ { { "key" "value" } } ] [
    "value" "key" <ternary-search-tree> [ set-at ] keep
    >alist
] unit-test

[ { { "key" "value" } { "foo" "bar" } } ] [
    <ternary-search-tree>
        "value" "key" pick set-at
        "bar" "foo" pick set-at
    >alist
] unit-test


! MEMO: dict-words ( -- seq )
!     "/usr/share/dict/words" ascii file-lines [ >lower ] map ;

dict-words [
    H{ } clone [ '[ dup _ set-at ] each ] keep
] time

dict-words [
    <ternary-search-tree> [ '[ dup _ set-at ] each ] keep
] time

[ 1000000 [ "zyx" over at drop ] times ] time




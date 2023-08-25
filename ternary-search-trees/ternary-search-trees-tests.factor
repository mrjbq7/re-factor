
USING: assocs fry kernel sequences sorting ternary-search-trees
tools.test ;

IN: ternary-search-trees

[ 0 ] [ <ternary-search-tree> assoc-size ] unit-test

[ 1 ] [
    <ternary-search-tree>
    "value" "key" pick set-at
    assoc-size
] unit-test

[ 1 ] [
    <ternary-search-tree>
    "value" "key" pick set-at
    "value" "key" pick set-at
    assoc-size
] unit-test

[ 0 ] [
    <ternary-search-tree>
    "value" "key" pick set-at
    "key" over delete-at
    "key" over delete-at
    assoc-size
] unit-test

[ "value" 1 ] [
    "value" "key" <ternary-search-tree>
    [ [ set-at ] [ at ] 2bi ] [ assoc-size ] bi
] unit-test

[ { { "key" "value" } } ] [
    "value" "key" <ternary-search-tree> [ set-at ] keep
    >alist
] unit-test

[ { { "foo" "bar" } { "key" "value" } } ] [
    <ternary-search-tree>
        "value" "key" pick set-at
        "bar" "foo" pick set-at
    >alist sort
] unit-test


! MEMO: dict-words ( -- seq )
!     "/usr/share/dict/words" ascii file-lines [ >lower ] map ;

! dict-words [
!     H{ } clone [ '[ dup _ set-at ] each ] keep
! ] time

! dict-words [
!     <ternary-search-tree> [ '[ dup _ set-at ] each ] keep
! ] time

! [ 1000000 H{ } clone '[ "zyx" _ at drop ] times ] time
! [ 1000000 <ternary-search-tree> '[ "zyx" _ at drop ] times ] time




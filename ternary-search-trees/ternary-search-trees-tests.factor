
USING: accessors arrays assocs fry hashtables kernel locals math
sequences sorting strings ternary-search-trees tools.test ;

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


! Exercise left/right branches, shared prefixes, empty and Unicode keys.
CONSTANT: test-keys
    { "cat" "bat" "rat" "car" "cart" "c" "" "猫" "猫咪" "é" "é" }

:: test-tree ( keys -- tree )
    <ternary-search-tree> :> tree
    keys [ dup tree set-at ] each
    tree ;

{ t } [| |
    test-keys test-tree :> tree
    test-keys [ dup tree at = ] all?
] unit-test

{ t } [| |
    test-keys reverse test-tree >alist
    test-keys test-tree >alist =
] unit-test

{ { "car" "cart" "cat" } } [| |
    "ca" test-keys test-tree prefix>alist keys
] unit-test

{ { "c" "car" "cart" "cat" } } [| |
    "c" test-keys test-tree prefix>alist keys
] unit-test

{ { "猫" "猫咪" } } [| |
    "猫" test-keys test-tree prefix>alist keys
] unit-test

{ { } } [ "cab" test-keys test-tree prefix>alist ] unit-test
{ { } } [ "" <ternary-search-tree> prefix>alist ] unit-test
{ t } [ test-keys test-tree >alist keys test-keys sort = ] unit-test

{ f t 1 } [| |
    <ternary-search-tree> :> tree
    f "" tree set-at
    "" tree at* tree assoc-size
] unit-test

{ f f 0 } [| |
    <ternary-search-tree> :> tree
    f "" tree set-at
    "" tree delete-at
    "" tree delete-at
    "" tree at* tree assoc-size
] unit-test

{ { "cart" "cat" } 10 } [| |
    test-keys test-tree :> tree
    "car" tree delete-at
    "ca" tree prefix>alist keys tree assoc-size
] unit-test

{ "car" "changed" t f } [| |
    test-keys test-tree :> original
    original clone :> copied
    "changed" "car" copied set-at
    "cat" copied delete-at
    "car" original at "car" copied at
    "cat" original key? "cat" copied key?
] unit-test

{ 0 { } f f } [| |
    test-keys test-tree :> tree
    tree clear-assoc
    tree assoc-size tree >alist "cat" tree at*
] unit-test

! Compare every step of a deterministic mutation sequence with a hash table.
{ t } [| |
    <ternary-search-tree> :> tree
    H{ } clone :> hash
    300 <iota> [| i |
        i 7 * test-keys length mod test-keys nth :> key
        i 3 mod zero? [
            key tree delete-at key hash delete-at
        ] [
            i even? [ f ] [ i ] if :> value
            value key tree set-at value key hash set-at
        ] if
        tree >alist hash >alist sort =
        tree assoc-size hash assoc-size = and
        test-keys [| k | k tree at* 2array k hash at* 2array = ] all? and
    ] all?
] unit-test

! Zero is a valid character, not the marker for an uninitialized node.
{ 42 t } [| |
    <ternary-search-tree> :> tree
    0 1string :> key
    42 key tree set-at
    key tree at*
] unit-test

! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators formatting hashtables
html.entities html.parser html.parser.analyzer html.parser.printer io
io.encodings.utf8 io.files io.styles kernel memoize sequences
sets splitting strings unicode wrap.strings ;
IN: geekcode

ERROR: unsupported-geekcode-version version ;

<PRIVATE

: split-text ( str -- tokens )
    [ blank? ] split-when harvest ;

: normalized-text ( tags -- str )
    html-text html-unescape split-text " " join ;

: opening-tag? ( tag name -- ? )
    [ swap name>> = ] [ drop closing?>> not ] 2bi and ;

: heading? ( tag -- ? )
    name>> { "h1" "h2" } member? ;

: parse-ratings ( tags -- assoc )
    [ "dt" opening-tag? ] split-when rest [
        [ "dd" opening-tag? ] split1-when
        [ normalized-text ] bi@
    ] H{ } map>assoc ;

: parse-types ( tags -- assoc )
    [ "dd" opening-tag? ] split-when rest [
        normalized-text " " split1
        [ "- " member? ] trim-head
    ] H{ } map>assoc ;

: parse-spec ( tags -- spec )
    [ [ heading? ] [ closing?>> not ] bi and ] split-when rest [
        [ heading? ] split1-when
        [ normalized-text ] [ "dl" find-between-first ] bi*
        over "Types of Geeks" = [
            nip parse-types "Type" swap
        ] [ parse-ratings ] if 2array
    ] map [
        [ second assoc-empty? ]
        [ first { "Variables" "Where to find the Geek Code" } member? ] bi or
    ] reject ;

MEMO: geekcode-spec ( -- spec )
    "vocab:geekcode/geekcode-3.12.html" utf8 file-contents
    parse-html parse-spec ;

MEMO:: code-table ( -- assoc )
    H{ } clone :> table
    geekcode-spec [
        first2 :> ( name ratings )
        ratings [| code description |
            name description 2array code table set-at
        ] assoc-each
    ] each table ;

: lookup-code ( code -- row/f )
    code-table at ;

:: lookup-types ( code -- row/f )
    code "/" split unclip :> ( more first-code )
    first-code "Type" geekcode-spec at at :> first-description
    more [ "G" prepend "Type" geekcode-spec at at ] map
    first-description prefix :> descriptions
    descriptions [ ] all? [
        "Type" descriptions "; " join 2array
    ] [ f ] if ;

:: add-note ( row note -- row' )
    row first row second note " " glue 2array ;

! Shape has independent height and build ratings; the published table
! only spells out the diagonal combinations.
CONSTANT: shape-ratings H{
    { "+++" { "very tall" "very heavy" } }
    { "++" { "tall" "heavy" } }
    { "+" { "above average" "above average" } }
    { "" { "average" "average" } }
    { "-" { "below average" "thin" } }
    { "--" { "short" "very thin" } }
    { "---" { "very short" "extremely thin" } }
}

:: lookup-shape ( code -- row/f )
    code rest ":" split1 :> ( height build )
    height shape-ratings at :> h
    build shape-ratings at :> b
    h b and [
        "Shape" h first b second "Height: %s; build: %s." sprintf 2array
    ] [ f ] if ;

CONSTANT: unix-flavors H{
    { CHAR: B "BSD" } { CHAR: L "Linux" } { CHAR: U "Ultrix" }
    { CHAR: A "AIX" } { CHAR: V "SysV" } { CHAR: H "HPUX" }
    { CHAR: I "IRIX" } { CHAR: O "OSF/1 (Digital Unix)" }
    { CHAR: S "Sun OS/Solaris" } { CHAR: C "SCO Unix" }
    { CHAR: X "NeXT" } { CHAR: * "other Unix" }
}

:: lookup-unix ( code -- row/f )
    code rest :> body
    body [ unix-flavors key? ] trim-head :> rating
    rating "U" prepend lookup-code [
        body rating length head* [ unix-flavors at ] { } map-as
        ", " join "Systems: " "." surround add-note
    ] [ f ] if* ;

:: lookup-sex ( code -- row/f )
    code "!" ?head :> ( body refused? )
    body first H{ { CHAR: x "Female." } { CHAR: y "Male." }
        { CHAR: z "Gender undisclosed." } } at :> gender
    body rest "z" prepend refused? [ "!" prepend ] when :> normalized
    normalized lookup-code [ ] [
        normalized [ CHAR: * = ] trim-tail :> base
        base lookup-code :> main
        normalized base length tail "z" prepend lookup-code :> extra
        main extra and [ main extra second add-note ] [ f ] if
    ] if* [ gender add-note ] [ f ] if* ;

! Explicit entries retain their wording and override generic modifiers.
: lookup-rating ( code -- row/f )
    dup lookup-code [ nip ] [
        dup "!" ?head drop ?first {
            { CHAR: s [ dup "s" head? [ lookup-shape ] [ drop f ] if ] }
            { CHAR: U [ dup "U" head? [ lookup-unix ] [ drop f ] if ] }
            { CHAR: x [ lookup-sex ] }
            { CHAR: y [ lookup-sex ] }
            { CHAR: z [ lookup-sex ] }
            [ drop lookup-types ]
        } case
    ] if* ;

: rating-prefix ( code -- prefix )
    "!" ?head drop
    dup "U" head? "+-:!?@$/()" "+-:!?*@$/()" ?
    '[ _ member? ] split1-when drop ;

:: variable-row ( category description -- row/f )
    category dup rating-prefix = [
        category "s" = [ "Shape" ] [
            category lookup-rating [ first ] [ f ] if*
        ] if [ description 2array ] [ f ] if*
    ] [ f ] if ;

:: lookup-variable ( code -- row/f )
    {
        { [ code "?" tail? ] [
            code 1 head* "I have no knowledge of this category." variable-row
        ] }
        { [ code "!" head? ] [
            code rest "I refuse to participate in this category." variable-row
        ] }
        [ f ]
    } cond ;

: decode-rating ( code -- row/f )
    dup lookup-rating [ nip ] [ lookup-variable ] if* ;

:: add-related-rating ( row related label -- row/f )
    row related and [
        row first related first = [
            row related second label prepend add-note
        ] [ f ] if
    ] [ f ] if ;

:: decode-range ( code -- row/f )
    code "(" split1 :> ( base range )
    range [
        range ")" ?tail [
            base rating-prefix prepend decode-rating :> alternative
            base decode-rating alternative "Range: " add-related-rating
        ] [ drop f ] if
    ] [ base decode-rating ] if ;

:: decode-modifiers ( code -- row/f )
    code [ "@$" member? ] trim-tail :> base
    code base length tail :> modifiers
    modifiers all-unique? [
        base decode-range [
            CHAR: @ modifiers member? [
                "This rating varies with circumstances." add-note
            ] when
            CHAR: $ modifiers member? [
                "I do this for a living." add-note
            ] when
        ] [ f ] if*
    ] [ f ] if ;

:: decode-code ( code -- row/f )
    code ">" split1 :> ( current target )
    current decode-modifiers :> row
    {
        { [ target not ] [ row ] }
        { [ row not ] [ f ] }
        { [ target empty? ] [ f ] }
        { [ target "$" = ] [
            row "I would like to do this for a living." add-note
        ] }
        [
            row current rating-prefix target append decode-modifiers
            "Goal: " add-related-rating
        ]
    } cond ;

: code-line ( line -- line' )
    [ blank? ] trim
    dup {
        "-----BEGIN GEEK CODE BLOCK-----"
        "------END GEEK CODE BLOCK------"
    } member? [ drop "" ] [
        dup "Version:" head? [
            "Version:" ?head drop [ blank? ] trim
            dup { "3.1" "3.12" } member?
            [ drop "" ] [ unsupported-geekcode-version ] if
        ] when
    ] if ;

: code-tokens ( str -- tokens )
    string-lines [ code-line split-text ] map concat ;

: decode-tokens ( str -- decoded )
    code-tokens [ dup decode-code 2array ] map ;

PRIVATE>

: geekcode ( str -- rows )
    decode-tokens values sift [ [ clone ] map ] map ;

: geekcode-unknown ( str -- tokens )
    decode-tokens [ not ] filter-values keys ;

: geekcode. ( str -- )
    decode-tokens dup values sift standard-table-style [
        [
            [
                [ [ write ] with-cell ]
                [ [ 60 wrap-string write ] with-cell ] bi*
            ] with-row
        ] assoc-each
    ] tabular-output nl
    [ not ] filter-values keys [
        "Unrecognized codes: " write " " join print
    ] unless-empty ;

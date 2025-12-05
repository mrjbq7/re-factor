! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators
combinators.short-circuit combinators.smart formatting
hashtables io io.encodings.utf8 io.files kernel keyboard make
math math.combinatorics math.functions math.order math.parser
namespaces ranges regexp sequences sets sorting splitting
strings unicode ;

IN: zxcvbn

! https://github.com/dropbox/zxcvbn

! Password strength estimator based on Dropbox's zxcvbn
! 0: too guessable
! 1: very guessable
! 2: somewhat guessable
! 3: safely unguessable
! 4: very unguessable

<PRIVATE

TUPLE: match
    pattern i j token
    { matched-word initial: f }
    { rank initial: f }
    { dictionary-name initial: f }
    { reversed initial: f }
    { l33t initial: f }
    { sub initial: f }
    { ascending initial: f }
    { sequence-name initial: f }
    { sequence-space initial: f }
    { graph initial: f }
    { turns initial: f }
    { shifted-count initial: 0 }
    { regex-name initial: f }
    { regex-match initial: f }
    { separator initial: f }
    { year initial: f }
    { month initial: f }
    { day initial: f }
    { repeat-count initial: 1 }
    { base-token initial: f }
    { base-guesses initial: f }
    { base-matches initial: f }
    { guesses initial: f } ;

: <match> ( pattern i j token -- match )
    match new
        swap >>token
        swap >>j
        swap >>i
        swap >>pattern ;

CONSTANT: START_UPPER R/ ^[A-Z][^A-Z]+$/
CONSTANT: END_UPPER R/ ^[^A-Z]+[A-Z]$/
CONSTANT: ALL_UPPER R/ ^[^a-z]+$/
CONSTANT: ALL_LOWER R/ ^[^A-Z]+$/

! Feedback generation for password strength

:: dictionary-warning ( match is-sole-match -- warning/f )
    match dictionary-name>> {
        { "passwords" [
            is-sole-match
            match l33t>> not and
            match reversed>> not and [
                {
                    { [ match rank>> 10 <= ] [ "This is a top-10 common password." ] }
                    { [ match rank>> 100 <= ] [ "This is a top-100 common password." ] }
                    [ "This is a very common password." ]
                } cond
            ] [
                ! For l33t or reversed passwords
                match guesses>> [ log10 ] [ 0 ] if* 4 <=
                "This is similar to a commonly used password."
                and
            ] if
        ] }
        { "english_wikipedia" [
            is-sole-match "A word by itself is easy to guess." and
        ] }
        { "surnames" [
            is-sole-match
            "Names and surnames by themselves are easy to guess."
            "Common names and surnames are easy to guess." ?
        ] }
        { "male_names" [
            is-sole-match
            "Names and surnames by themselves are easy to guess."
            "Common names and surnames are easy to guess." ?
        ] }
        { "female_names" [
            is-sole-match
            "Names and surnames by themselves are easy to guess."
            "Common names and surnames are easy to guess." ?
        ] }
        [ drop f ]
    } case ;

:: dictionary-suggestions ( match -- suggestions )
    [
        match token>> :> word

        word START_UPPER matches? [
            "Capitalization doesn't help very much." ,
        ] when

        word ALL_UPPER matches? word >lower word = not and [
            "All-uppercase is almost as easy to guess as all-lowercase." ,
        ] when

        match reversed>> match token>> length 4 >= and [
            "Reversed words aren't much harder to guess." ,
        ] when

        match l33t>> [
            "Predictable substitutions like '@' instead of 'a' don't help very much." ,
        ] when
    ] { } make ;

:: (get-feedback) ( match is-sole-match -- feedback )
    match pattern>> {
        { "dictionary" [
            H{ } clone
            match is-sole-match dictionary-warning "warning" pick set-at
            match dictionary-suggestions "suggestions" pick set-at
        ] }
        { "spatial" [
            match turns>> 1 =
            "Straight rows of keys are easy to guess."
            "Short keyboard patterns are easy to guess." ? :> warning
            H{
                { "warning" warning }
                { "suggestions"
                    V{ "Use a longer keyboard pattern with more turns." }
                }
            }
        ] }
        { "repeat" [
            match base-token>> length 1 =
            "Repeats like \"aaa\" are easy to guess."
            "Repeats like \"abcabcabc\" are only slightly harder to guess than \"abc\"." ? :> warning
            H{
                { "warning" warning }
                { "suggestions"
                    V{ "Avoid repeated words and characters." }
                }
            }
        ] }

        { "sequence" [
            H{
                { "warning" "Sequences like \"abc\" or \"6543\" are easy to guess." }
                { "suggestions" V{ "Avoid sequences." } }
            }
        ] }

        { "regex" [
            match regex-name>> "recent_year" = [
                H{
                    { "warning" "Recent years are easy to guess." }
                    { "suggestions"
                        V{
                            "Avoid recent years."
                            "Avoid years that are associated with you."
                        }
                    }
                }
            ] [
                H{ }
            ] if
        ] }

        { "date" [
            H{
                { "warning" "Dates are often easy to guess." }
                { "suggestions" V{ "Avoid dates and years that are associated with you." } }
            }
        ] }

        [ drop H{ } ]
    } case ;

CONSTANT: EMPTY_FEEDBACK H{
    { "suggestions" V{
        "Use a few words, avoid common phrases."
        "No need for symbols, digits, or uppercase letters."
    } }
}

CONSTANT: DEFAULT_SUGGESTION "Add another word or two. Uncommon words are better."

: longest-match ( sequence -- match )
    [ token>> length ] supremum-by ;

: get-feedback ( score sequence -- feedback )
    {
        { [ dup empty? ] [ 2drop EMPTY_FEEDBACK ] }
        { [ over 2 > ] [ 2drop f ] }
        [
            nip [ longest-match ] [ length 1 = ] bi (get-feedback)
            clone "suggestions" over [ DEFAULT_SUGGESTION prefix ] change-at
        ]
    } cond ;

! These are frequency lists and rank cutoffs, stored in the same
! order as the original Dropbox library for compatibility.

CONSTANT: frequency-cutoffs {
    { "surnames" 10000 }
    { "male_names" f }
    { "female_names" f }
    { "english_wikipedia" 30000 }
    { "us_tv_and_film" 30000 }
    { "passwords" 30000 }
}

: make-frequency-list ( lines -- assoc )
    H{ } clone [
        '[ 1 + swap " " split1 drop "\\'" "'" replace _ set-at ] each-index
    ] keep ;

: load-frequency-list ( name -- assoc )
    "vocab:zxcvbn/" ".txt" surround utf8 file-lines make-frequency-list ;

: load-frequency-lists ( -- assoc )
    frequency-cutoffs keys [ dup load-frequency-list ] H{ } map>assoc ;

:: find-minimum-ranks ( raw-lists -- ranks )
    H{ } clone :> ranks
    frequency-cutoffs keys [| name |
        name raw-lists at [| token rank |
            token ranks at [ second rank > ] [ t ] if* [
                { name rank } token ranks set-at
            ] when
        ] assoc-each
    ] each ranks ;

:: filter-collect-ranks ( ranks -- ranks' )
    H{ } clone :> result
    ranks [
        first2 :> ( token name rank )
        token length 10^ rank <= ! is rare and short?
        token [ ",\"" member? ] any? or ! has comma or quote?
        [ { token rank } name result push-at ] unless
    ] assoc-each result ;

: sort-cutoff-ranks ( ranks -- ranks' )
    [
        sort-values keys over frequency-cutoffs at
        [ index-or-length head ] when* make-frequency-list
    ] assoc-map ;

MEMO: ranked-dictionaries ( -- assoc )
    load-frequency-lists find-minimum-ranks
    filter-collect-ranks sort-cutoff-ranks ;

! Dictionary matching

:: dictionary-match ( password ranked-dictionaries -- matches )
    password >lower :> password'
    V{ } clone :> matches
    ranked-dictionaries [| dict-name dict |
        password length :> len
        len [0..b) [| i |
            i 1 + len [a..b] [| j |
                i j password' subseq :> word
                word dict at [| rank |
                    "dictionary" i j 1 - i j password subseq <match>
                        dict-name >>dictionary-name
                        word >>matched-word
                        rank >>rank
                        f >>l33t
                        f >>reversed
                    matches push
                ] when*
            ] each
        ] each
    ] assoc-each
    matches ;

! Reverse dictionary matching

:: reverse-dictionary-match ( password ranked-dictionaries -- matches )
    password length :> len
    password reverse ranked-dictionaries dictionary-match [
        [ reverse ] change-matched-word
        [ reverse ] change-token
        t >>reversed
        ! Remap coordinates back to original password
        dup [ i>> ] [ j>> ] bi
        [ len 1 - swap - ] bi@
        swap [ >>i ] [ >>j ] bi*
    ] map ;

! L33t matching

CONSTANT: L33T-TABLE H{
    { CHAR: a "4@" }
    { CHAR: b "8" }
    { CHAR: c "({[<" }
    { CHAR: e "3" }
    { CHAR: g "69" }
    { CHAR: i "1!|" }
    { CHAR: l "1|7" }
    { CHAR: o "0" }
    { CHAR: s "$5" }
    { CHAR: t "+7" }
    { CHAR: x "%" }
    { CHAR: z "2" }
}

: l33t-subtable ( password -- assoc )
    ! Keep only l33t chars that are actually in the password
    [ L33T-TABLE ] dip >lower
    '[ [ _ member? ] filter ] assoc-map
    [ empty? ] reject-values ;

:: l33t-subs ( table -- subs )
    ! Generate possible l33t character mappings
    V{ } clone 1array :> subs!
    table [| orig-chr l33t-chrs |
        V{ } clone :> next-subs
        l33t-chrs [| l33t-chr |
            subs [| sub |
                sub clone :> extended
                ! Check if l33t-chr is already in sub, if so
                ! keep original AND create alternative
                sub [ first l33t-chr = ] find drop [
                    sub next-subs push
                    extended remove-nth! drop
                ] when*
                l33t-chr orig-chr 2array extended push
                extended next-subs push
            ] each
        ] each next-subs members subs!
    ] assoc-each subs harvest [ >hashtable ] map ;

:: l33t-match ( password ranked-dictionaries -- matches )
    V{ } clone :> matches
    password l33t-subtable l33t-subs [| sub |
        password sub substitute ranked-dictionaries dictionary-match
        [| match |
            match i>> match j>> 1 + password subseq :> token
            token >lower :> lower-token
            lower-token match matched-word>> = [
                sub [ token member? ] filter-keys :> match-sub
                match-sub assoc-empty? [
                    match
                        token >>token
                        t >>l33t
                        match-sub >>sub
                    matches push
                ] unless
            ] unless
        ] each
    ] each
    ! Filter out single-character l33t matches
    matches [ token>> length 1 > ] filter
    [ [ i>> ] [ j>> ] bi 2array ] sort-by ;

! Spatial matching
CONSTANT: SHIFTED_RX "~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:\"ZXCVBNM<>?"

:: (spatial-match) ( password graph graph-name -- matches )
    graph-name { "qwerty" "dvorak" } member? :> qwerty?
    V{ } clone :> matches
    0 :> i!

    [ i password length 1 - < ] [
        i 1 + :> j!
        f :> last-direction!
        0 :> turns!

        ! Check if initial character is shifted (for qwerty/dvorak only)
        qwerty? [ i password nth SHIFTED_RX member? ] [ f ] if 1 0 ? :> shifted-count!

        t :> continue!
        [ continue ] [
            j 1 - password nth :> prev-char
            f :> found!
            -1 :> found-direction!
            -1 :> cur-direction!

            graph prev-char of [ { } ] unless* :> adjacents

            ! Consider growing pattern by one character if j hasn't gone over the edge
            j password length < [
                j password nth :> cur-char
                adjacents [| adj |
                    cur-direction 1 + cur-direction!
                    adj [ cur-char swap member? ] [ f ] if* [
                        t found!
                        cur-direction found-direction!
                        ! Check if this is a shifted character (index 1 in adjacency)
                        cur-char adj index 1 = [
                            shifted-count 1 + shifted-count!
                        ] when
                        found-direction last-direction = [
                            turns 1 + turns!
                            found-direction last-direction!
                        ] unless
                    ] when
                ] each
            ] when

            ! If the current pattern continued, extend j and try to grow again
            found [
                j 1 + j!
            ] [
                ! Otherwise push the pattern discovered so far, if any
                j i - 2 > [
                    "spatial" i j 1 - i j password subseq <match>
                        graph-name >>graph
                        turns >>turns
                        shifted-count >>shifted-count
                    matches push
                ] when
                ! Start a new search for the rest of the password
                j i!
                f continue!
            ] if
        ] while
    ] while

    matches ;

: spatial-match ( password -- matches )
    {
        [ qwerty-graph "qwerty" (spatial-match) ]
        [ dvorak-graph "dvorak" (spatial-match) ]
        [ keypad-graph "keypad" (spatial-match) ]
        [ mac-keypad-graph "mac_keypad" (spatial-match) ]
    } cleave>array concat ;

! Repeat matching - forward declarations
DEFER: omnimatch
DEFER: most-guessable-match-sequence

: analyze-repeat-base ( base-token -- base-analysis )
    dup f omnimatch most-guessable-match-sequence ;

:: string-repeats? ( s p -- ? )
    ! Check if string s is made of repeating pattern p
    s length p length mod 0 = [
        s length p length / :> n
        n 1 > [
            n <iota> [ p length * dup p length + s <slice> p sequence= ] all?
        ] [ f ] if
    ] [ f ] if ;

:: find-base-pattern ( s -- base-pattern/f )
    ! Find shortest repeating base pattern in string
    s length 2 /i [ f ] [
        [1..b] [| len |
            s len head :> candidate
            s candidate string-repeats? candidate and
        ] map-find drop
    ] if-zero ;

:: find-greedy-repeat ( s start -- end base-token/f )
    ! Find greedy repeat at position (longest repeating pattern)
    s length start - :> max-len
    max-len 2 < [ start f ] [
        f f :> ( best-end! best-base! )
        max-len 2 [a..b] [| len |
            best-base [
                start start len + s <slice> find-base-pattern
                [ best-base! start len + best-end! ] when*
            ] unless
        ] each
        best-end best-base
    ] if ;

:: find-lazy-repeat ( s start -- end base-token/f )
    ! Find lazy repeat at position (shortest repeating unit)
    s length start - 2 < [ start f ] [
        f :> result-end!
        f :> result-base!
        ! Try each possible base length from 1 up
        s length start - 2 /i [1..b] [| base-len |
            result-base [
                start start base-len + s subseq :> base

                ! Count how many times this base repeats starting at start
                1 :> total!
                [
                    start base-len total * + :> next-start
                    next-start base-len + s length <= [
                        next-start next-start base-len + s <slice>
                        base sequence=
                    ] [ f ] if
                ] [
                    total 1 + total!
                ] while

                total 2 >= [
                    start base-len total * + result-end!
                    base result-base!
                ] when
            ] unless

        ] each
        result-end result-base
    ] if ;

:: repeat-match ( password -- matches )
    [
        0 :> last-i!

        [ last-i password length < ] [
            password last-i find-greedy-repeat :> greedy-base :> greedy-end
            password last-i find-lazy-repeat :> ( lazy-end! lazy-base! )

            greedy-base [
                lazy-base [
                    greedy-end last-i - lazy-end last-i - >
                ] [ f ] if
            ] [ f ] if [
                greedy-end lazy-end!
                last-i greedy-end password subseq find-base-pattern lazy-base!
            ] when

            lazy-base [
                last-i :> i
                lazy-end 1 - :> j
                lazy-base analyze-repeat-base :> base-analysis

                lazy-end last-i - lazy-base length / :> repeat-count
                "repeat" i j i j 1 + password subseq <match>
                    lazy-base >>base-token
                    base-analysis "guesses" of >>base-guesses
                    base-analysis "sequence" of >>base-matches
                    repeat-count >>repeat-count ,

                j last-i!
            ] when

            last-i 1 + last-i!
        ] while
    ] { } make ;

! Sequence matching

CONSTANT: MAX_DELTA 5

:: sequence-update ( i j delta password -- )
    j i - 1 > delta abs 1 = or [
        delta abs 1 MAX_DELTA between? [
            i j 1 + password subseq :> token
            {
                { [ token R/ ^[a-z]+$/ matches? ] [ "lower" 26 ] }
                { [ token R/ ^[A-Z]+$/ matches? ] [ "upper" 26 ] }
                { [ token R/ ^\d+$/ matches? ] [ "digits" 10 ] }
                [ "unicode" 26 ]
            } cond :> ( sequence-name sequence-space )

            "sequence" i j token <match>
                sequence-name >>sequence-name
                sequence-space >>sequence-space
                delta 0 > >>ascending ,
        ] when
    ] when ;

:: sequence-match ( password -- matches )
    [
        password length :> len
        len 1 > [
            0 :> i!
            f :> last-delta!

            len 1 - [1..b] [| k |
                k password nth k 1 - password nth - :> delta
                last-delta delta last-delta = not and [
                    i k 1 - last-delta password sequence-update
                    k 1 - i!
                ] when delta last-delta!
            ] each

            i len 1 - last-delta password sequence-update
        ] when
    ] { } make ;

! Regex matching

:: regex-match ( password -- matches )
    H{
        { "recent_year" R/ 19\d\d|200\d|201\d/ }
    } [| name regex |
        password regex all-matching-slices [| s |
            s from>> :> start
            s to>> 1 - :> end
            s >string :> token
            "regex" start end token <match>
                name >>regex-name
                token >>regex-match
        ] map
    ] { } assoc>map concat ;

! Date matching

CONSTANT: DATE_MAX_YEAR 2050
CONSTANT: DATE_MIN_YEAR 1000
CONSTANT: REFERENCE_YEAR 2017 ! $[ now year>> ]
CONSTANT: DATE_SPLITS H{
    { 4 { { 1 2 } { 2 3 } } }
    { 5 { { 1 3 } { 2 3 } } }
    { 6 { { 1 2 } { 2 4 } { 4 5 } } }
    { 7 { { 1 3 } { 2 3 } { 4 5 } { 4 6 } } }
    { 8 { { 2 4 } { 4 6 } } }
}

: 2-to-4-digit-year ( year -- year' )
    {
        { [ dup 99 > ] [ ] }
        { [ dup 50 > ] [ 1900 + ] }
        [ 2000 + ]
    } cond ;

:: maybe-date? ( i1 i2 i3 -- ? )
    ! Middle int must be <= 31 and > 0 (years are never in the middle)
    i2 1 31 between? [
        ! Check for invalid values
        0 :> over-12!
        0 :> over-31!
        0 :> under-1!
        f :> invalid!
        i1 i2 i3 [| i |
            ! Values between 100-999 are invalid (too big for 2-digit year,
            ! too small for 4-digit year)
            i 99 > i DATE_MIN_YEAR < and [ t invalid! ] when
            i DATE_MAX_YEAR > [ t invalid! ] when
            i 31 > [ over-31 1 + over-31! ] when
            i 12 > [ over-12 1 + over-12! ] when
            i 0 <= [ under-1 1 + under-1! ] when
        ] tri@
        invalid over-31 2 >= or over-12 3 = or under-1 2 >= or not
    ] [ f ] if ;

:: day-month ( i1 i2 -- dm/f )
    i1 1 31 between? i2 1 12 between? and [
        H{ { "day" i1 } { "month" i2 } }
    ] [
        i2 1 31 between? i1 1 12 between? and [
            H{ { "day" i2 } { "month" i1 } }
        ] [ f ] if
    ] if ;

:: check-date ( i1 i2 i3 -- date/f )
    i1 i2 i3 maybe-date? [
        {
            ! dm + yyyy
            { [ i3 DATE_MIN_YEAR DATE_MAX_YEAR between? ] [
                i1 i2 day-month dup [
                    clone i3 "year" pick set-at
                ] when ] }

            ! yyyy-dm
            { [ i1 DATE_MIN_YEAR DATE_MAX_YEAR between? ] [
                i2 i3 day-month dup [
                    clone i1 "year" pick set-at
                ] when ] }

            [
                ! dm + yy
                i1 i2 day-month [
                    clone i3 2-to-4-digit-year "year" pick set-at
                ] [
                    ! yy + dm
                    i2 i3 day-month [
                        clone i1 2-to-4-digit-year "year" pick set-at
                    ] [ f ] if*
                ] if*
            ]
        } cond
    ] [ f ] if ;

:: date-match ( password -- matches )
    password length :> len
    V{ } clone :> matches

    ! Dates without separators are between length 4 '1191' and 8 '11111991'
    len 3 [-] [0..b] [| i |
        i 4 + :> min-j
        i 9 + len min :> max-j
        min-j max-j <= [
            min-j max-j [a..b] [| j |
                i j password subseq :> token
                token [ digit? ] all? [
                    DATE_SPLITS token length of [
                        ! Collect all valid date candidates for this token
                        [
                            first2 :> ( k l )
                            token k head-slice string>number
                            k l token <slice> string>number
                            token l tail-slice string>number
                            check-date
                        ] map sift [
                            ! Pick the best candidate: year closest to REFERENCE_YEAR
                            [ "year" of REFERENCE_YEAR - abs ] infimum-by :> best
                            "date" i j 1 - token <match>
                                "" >>separator
                                best "year" of >>year
                                best "month" of >>month
                                best "day" of >>day
                            matches push
                        ] unless-empty
                    ] when*
                ] when
            ] each
        ] when
    ] each

    ! Dates with separators are between length 6 '1/1/91' and 10 '11/11/1991'
    ! Pattern: 1-4 digits, separator, 1-2 digits, same separator, 1-4 digits
    len 5 [-] [0..b] [| i |
        i 6 + :> min-j2
        i 11 + len min :> max-j2
        min-j2 max-j2 <= [
            min-j2 max-j2 [a..b] [| j |
                i j password subseq :> token
                ! Try to parse: digits separator digits separator digits
                f :> parsed!
                4 [1..b] [| len1 |
                    {
                        [ parsed not len1 1 + token length < and ]
                        [ token len1 head [ digit? ] all? ]
                    } 0&& [
                        len1 token nth :> sep
                        sep " /\\._-" member? [
                            ! Find second separator (middle part is 1-2 digits)
                            len1 1 + :> start2
                            2 [1..b] [| len2 |
                                {
                                    [ parsed not start2 len2 + token length < and ]
                                    [ start2 start2 len2 + token <slice> [ digit? ] all? ]
                                    [ start2 len2 + token nth sep = ]
                                } 0&& [
                                    ! Found matching separator
                                    start2 len2 + 1 + :> start3
                                    token start3 tail-slice {
                                        [ [ digit? ] all? ]
                                        [ length 1 4 between? ]
                                    } 1&& [
                                        V{ } clone :> ints
                                        token len1 head string>number ints push
                                        start2 start2 len2 + token subseq string>number ints push
                                        token start3 tail string>number ints push
                                        ints sep 1string 2array parsed!
                                    ] when
                                ] when
                            ] each
                        ] when
                    ] when
                ] each
                parsed [
                    first2 :> sep
                    first3 check-date [| date |
                        "date" i j 1 - token <match>
                            sep >>separator
                            date "year" of >>year
                            date "month" of >>month
                            date "day" of >>day
                        matches push
                    ] when*
                ] when*
            ] each
        ] when
    ] each

    ! Filter out submatches to reduce noise
    matches [| match |
        matches [| other |
            match other = not
            other i>> match i>> <= and
            other j>> match j>> >= and
        ] none?
    ] filter ;

:: omnimatch ( password user-inputs -- matches )
    user-inputs [ [ >lower ] map make-frequency-list ] [ { } ] if*
    "user_inputs" ranked-dictionaries set-at

    password {
        [ ranked-dictionaries dictionary-match ]
        [ ranked-dictionaries reverse-dictionary-match ]
        [ ranked-dictionaries l33t-match ]
        [ spatial-match ]
        [ repeat-match ]
        [ sequence-match ]
        [ regex-match ]
        [ date-match ]
    } cleave>array concat ;

DEFER: estimate-guesses

CONSTANT: BRUTEFORCE_CARDINALITY 10
CONSTANT: MIN_GUESSES_BEFORE_GROWING_SEQUENCE 10000
CONSTANT: MIN_SUBMATCH_GUESSES_SINGLE_CHAR 10
CONSTANT: MIN_SUBMATCH_GUESSES_MULTI_CHAR 50
CONSTANT: MIN_YEAR_SPACE 20

: bruteforce-guesses ( match -- #guesses )
    ! +1 so non-bruteforce submatches over the same [i..j] take precedence
    token>> length
    [ 1 = MIN_SUBMATCH_GUESSES_SINGLE_CHAR MIN_SUBMATCH_GUESSES_MULTI_CHAR ? 1 + ]
    [ BRUTEFORCE_CARDINALITY swap ^ ] bi max ;

:: uppercase-variations ( token -- #variations )
    {
        { [ token ALL_LOWER matches? ] [ 1 ] }
        { [ token ALL_UPPER matches? ] [ 2 ] }
        { [ token START_UPPER matches? ] [ 2 ] }
        { [ token END_UPPER matches? ] [ 2 ] }
        [
            token [ LETTER? ] count :> #upper
            token [ letter? ] count :> #lower
            #upper #lower + [ 1 ] [
                #upper #lower min [1..b] [ nCk ] with map-sum
            ] if-zero
        ]
    } cond ;

:: l33t-variations ( match -- #variations )
    match l33t>> [
        match token>> >lower :> token-lower
        match sub>> 1 [| subbed-chr unsubbed-chr |
            token-lower [ subbed-chr = ] count :> S
            token-lower [ unsubbed-chr = ] count :> U
            S 0 = U 0 = or [
                ! Fully subbed or fully unsubbed - doubles the space
                2
            ] [
                ! Mixed case - calculate combinations
                S U min [1..b] [| i | S U + i nCk ] map-sum
            ] if *
        ] assoc-reduce
    ] [ 1 ] if ;

:: dictionary-guesses ( match -- #guesses )
    match reversed>> 2 1 ?
    match l33t>> [ match l33t-variations ] [ 1 ] if
    match token>> uppercase-variations * *
    match rank>> * ;

:: spatial-guesses ( match -- #guesses )
    match token>> length :> L
    match turns>> :> turns
    match graph>> {
        { "qwerty" [ qwerty-graph assoc-size qwerty-avg-degree ] }
        { "dvorak" [ dvorak-graph assoc-size dvorak-avg-degree ] }
        { "keypad" [ keypad-graph assoc-size keypad-avg-degree ] }
        ! Note: JavaScript uses keypad size and avg-degree for mac_keypad too
        { "mac_keypad" [ keypad-graph assoc-size keypad-avg-degree ] }
    } case :> ( s d )

    0 :> guesses!
    ! Estimate number of possible patterns w/ length L or less with turns or less
    2 L [a..b] [| i |
        i 1 - turns min 1 + :> possible-turns
        possible-turns [1..b) [| j |
            i 1 - j 1 - nCk s * d j ^ * guesses + guesses!
        ] each
    ] each

    ! Add extra guesses for shifted keys
    match shifted-count>> 0 > [
        match shifted-count>> :> S
        L S - :> U  ! unshifted count
        S 0 = U 0 = or [
            guesses 2 * guesses!
        ] [
            S U min [1..b] [| i | S U + i nCk ] map-sum :> shift-variations
            guesses shift-variations * guesses!
        ] if
    ] when
    guesses ;

: repeat-guesses ( match -- #guesses )
    [ base-guesses>> ] [ repeat-count>> ] bi * ;

: sequence-guesses ( match -- #guesses )
    [ token>> first dup "aAzZ019" member? [ drop 4 ] [ digit? 10 26 ? ] if ]
    [ ascending>> 1 2 ? ]
    [ token>> length ] tri * * ;

CONSTANT: CHAR_CLASS_BASES H{
    { "alpha_lower" 26 }
    { "alpha_upper" 26 }
    { "alpha" 52 }
    { "alphanumeric" 62 }
    { "digits" 10 }
    { "symbols" 33 }
}

:: regex-guesses ( match -- #guesses )
    match regex-name>> :> regex-name
    match token>> :> token
    regex-name CHAR_CLASS_BASES at [
        token length ^
    ] [
        regex-name "recent_year" = [
            token string>number REFERENCE_YEAR - abs
            MIN_YEAR_SPACE max
        ] [
            MIN_YEAR_SPACE
        ] if
    ] if* ;

: date-guesses ( match -- #guesses )
    [ year>> REFERENCE_YEAR - abs MIN_YEAR_SPACE max 365 * ]
    [ separator>> empty? 1 4 ? ] bi * ;

: compute-guesses ( match -- #guesses )
    dup pattern>> {
        { "dictionary" [ dictionary-guesses ] }
        { "spatial" [ spatial-guesses ] }
        { "repeat" [ repeat-guesses ] }
        { "sequence" [ sequence-guesses ] }
        { "regex" [ regex-guesses ] }
        { "date" [ date-guesses ] }
        { "bruteforce" [ bruteforce-guesses ] }
        [ drop bruteforce-guesses ]
    } case ;

:: estimate-guesses ( match password -- #guesses )
    match compute-guesses
    ! Apply minimum guesses for submatches (tokens shorter than full password)
    match j>> match i>> - 1 + password length < [
        match token>> length 1 =
        MIN_SUBMATCH_GUESSES_SINGLE_CHAR
        MIN_SUBMATCH_GUESSES_MULTI_CHAR ? max
    ] when ;

! Dynamic programming for finding optimal match sequence

:: update-optimal ( m l opt-m opt-pi opt-g pw -- )
    m j>> :> k
    m pw estimate-guesses :> guesses
    guesses m guesses<<

    l 1 > [
        m i>> 1 - :> prev-k
        prev-k 0 >= [
            l 1 - prev-k opt-pi nth at :> prev-pi
            prev-pi [ guesses prev-pi * ] [ f ] if
        ] [ f ] if
    ] [
        guesses
    ] if :> pi

    pi [
        l factorial pi *
        MIN_GUESSES_BEFORE_GROWING_SEQUENCE l 1 - ^ + :> g

        f :> dominated?!
        k opt-g nth [| existing-l existing-g |
            existing-l l <= existing-g g <= and [
                t dominated?!
            ] when
        ] assoc-each

        dominated? [
            g l k opt-g nth set-at
            m l k opt-m nth set-at
            pi l k opt-pi nth set-at
        ] unless
    ] when ;

:: most-guessable-match-sequence ( password matches -- result )
    password length :> n
    H{
        { "password" password }
        { "guesses" 1 }
        { "sequence" V{ } }
    } clone :> result

    n 0 > [
        ! Partition matches by ending index j
        n [ V{ } clone ] replicate :> matches-by-j
        matches [| match |
            match j>> :> j
            j n < [ match j matches-by-j nth push ] when
        ] each
        ! Sort each by starting index
        matches-by-j [ [ i>> ] sort-by ] map! drop

        ! optimal[k] tracks best sequences ending at position k (0-indexed)
        ! Each entry is a hashtable mapping sequence-length -> { g pi match }
        n [ H{ } clone ] replicate :> optimal-m
        n [ H{ } clone ] replicate :> optimal-pi
        n [ H{ } clone ] replicate :> optimal-g

        n <iota> [| k |
            ! Consider matches ending at k
            k matches-by-j nth [| m |
                m i>> :> i
                i 0 > [
                    ! Extend sequences ending at i-1
                    i 1 - optimal-m nth keys [| l |
                        m l 1 + optimal-m optimal-pi optimal-g password update-optimal
                    ] each
                ] [
                    ! Start new sequence (match starts at 0)
                    m 1 optimal-m optimal-pi optimal-g password update-optimal
                ] if
            ] each

            ! First: try bruteforce spanning entire prefix 0..k as length-1
            "bruteforce" 0 k 0 k 1 + password subseq <match>
            1 optimal-m optimal-pi optimal-g password update-optimal

            ! Then: for each starting position i from 1 to k,
            ! try extending sequences at i-1 with bruteforce from i to k
            k 1 + [1..b) [| i |
                i 1 - optimal-m nth [| l last-m |
                    ! Skip if last match was bruteforce (adjacent bf not optimal)
                    last-m pattern>> "bruteforce" = [
                        "bruteforce" i k i k 1 + password subseq <match>
                        l 1 + optimal-m optimal-pi optimal-g password update-optimal
                    ] unless
                ] assoc-each
            ] each
        ] each

        ! Find best final sequence
        n 1 - optimal-g nth :> final-g
        final-g assoc-empty? [
            ! Find length with minimum g
            f 1/0. :> ( best-l! best-g! )
            final-g [| l g |
                g best-g < [ l best-l! g best-g! ] when
            ] assoc-each

            ! Unwind to get sequence
            V{ } clone :> seq
            n 1 - :> k!
            best-l :> l!

            [ l 0 > k 0 >= and ] [
                l k optimal-m nth at :> m
                m [
                    m seq push
                    m i>> 1 - k!
                    l 1 - l!
                ] [ k 1 - k! ] if
            ] while

            best-g "guesses" result set-at
            seq reverse "sequence" result set-at
        ] unless
    ] when result ;

: guesses-to-score ( #guesses -- score )
    { 1005 1000005 100000005 10000000005 } [ < ] with find drop 4 or ;

:: estimate-attack-times ( guesses -- times )
    H{ } clone
    guesses 100 3600 / / "online_throttling_100_per_hour" pick set-at
    guesses 10 / "online_no_throttling_10_per_second" pick set-at
    guesses 1e4 / "offline_slow_hashing_1e4_per_second" pick set-at
    guesses 1e10 / "offline_fast_hashing_1e10_per_second" pick set-at ;

PRIVATE>

INITIALIZED-SYMBOL: max-password-length [ 72 ]

:: zxcvbn-with-user-inputs ( password user-inputs -- result )
    password length max-password-length get > [
        "Password exceeds maximum length" throw
    ] when

    password user-inputs omnimatch :> matches
    password matches most-guessable-match-sequence :> result
    result "guesses" of guesses-to-score "score" result set-at
    result "guesses" of estimate-attack-times "attack" result set-at
    result "score" of result "sequence" of get-feedback "feedback" result set-at
    result ;

: zxcvbn ( password -- result )
    f zxcvbn-with-user-inputs ;

<PRIVATE

CONSTANT: score-labels {
    "too guessable"
    "very guessable"
    "somewhat guessable"
    "safely unguessable"
    "very unguessable"
}

: score. ( result -- )
    "score" of dup score-labels nth
    "Score:\n  %d/4 (%s)\n" printf ;

: crack-time. ( seconds -- string )
    {
        { [ dup 1 < ] [ drop "less than a second" ] }
        { [ dup 60 < ] [
            round >integer dup "%d second" sprintf
            swap 1 = [ "s" append ] unless
        ] }
        { [ dup 3600 < ] [
            60 / round >integer dup "%d minute" sprintf
            swap 1 = [ "s" append ] unless
        ] }
        { [ dup 86400 < ] [
            3600 / round >integer dup "%d hour" sprintf
            swap 1 = [ "s" append ] unless
        ] }
        { [ dup 2592000 < ] [
            86400 / round >integer dup "%d day" sprintf
            swap 1 = [ "s" append ] unless
        ] }
        { [ dup 31536000 < ] [
            2592000 / round >integer dup "%d month" sprintf
            swap 1 = [ "s" append ] unless
        ] }
        { [ dup 3153600000 < ] [
            31536000 / round >integer dup "%d year" sprintf
            swap 1 = [ "s" append ] unless
        ] }
        [ drop "centuries" ]
    } cond ;

: crack-times. ( result -- )
    "Crack times:" print
    "attack" of {
        { "online_throttling_100_per_hour" "  Online (throttled):   " }
        { "online_no_throttling_10_per_second" "  Online (unthrottled): " }
        { "offline_slow_hashing_1e4_per_second" "  Offline (slow hash):  " }
        { "offline_fast_hashing_1e10_per_second" "  Offline (fast hash):  " }
    } [ first2 write swap at crack-time. print ] with each ;

: feedback. ( result -- )
    "feedback" of
    [ "warning" of [ "Warning:\n  " write print ] unless-empty ]
    [ "suggestions" of [ "Suggestions:" print [ "  " write print ] each ] unless-empty ] bi ;

PRIVATE>

: zxcvbn. ( password -- )
    zxcvbn [ score. ] [ crack-times. ] [ feedback. ] tri ;

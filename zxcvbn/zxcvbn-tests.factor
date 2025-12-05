
USING: accessors assocs io.encodings.binary io.encodings.string
io.encodings.utf8 io.files kernel keyboard math
math.combinatorics math.functions math.order math.parser random
sequences splitting strings tools.test zxcvbn zxcvbn.private ;

! ============================================================
! uppercase-variations
! ============================================================

{ t } [
    {
        { "" 1 } { "a" 1 } { "password" 1 } { "abcdef" 1 } { "abcdefghijk" 1 }
        { "A" 2 } { "PASSWORD" 2 } { "ABCDEF" 2 } { "Password" 2 }
        { "Abcdef" 2 } { "Abcdefghijk" 2 } { "passworD" 2 } { "abcdeF" 2 }
        { "aBcdef" 6 } { "ABCDEf" 6 }
        { "aBcDef" 21 } { "aBCDEf" 21 }
        { "ABCdef" 41 }
    } [ first2 [ uppercase-variations ] dip = ] all?
] unit-test

! ============================================================
! l33t-variations
! ============================================================

{ 1 } [ T{ match { l33t f } } l33t-variations ] unit-test
{ 1 } [ T{ match { token "" } { l33t f } { sub H{ } } } l33t-variations ] unit-test
{ 1 } [ T{ match { token "a" } { l33t f } { sub H{ } } } l33t-variations ] unit-test
{ 1 } [ T{ match { token "abcet" } { l33t f } { sub H{ } } } l33t-variations ] unit-test
{ 2 } [ T{ match { token "4" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } } } } l33t-variations ] unit-test
{ 2 } [ T{ match { token "4pple" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } } } } l33t-variations ] unit-test
{ 2 } [ T{ match { token "4bcet" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } } } } l33t-variations ] unit-test
{ 2 } [ T{ match { token "a8cet" } { l33t t } { sub H{ { CHAR: 8 CHAR: b } } } } l33t-variations ] unit-test
{ 2 } [ T{ match { token "abce+" } { l33t t } { sub H{ { CHAR: + CHAR: t } } } } l33t-variations ] unit-test
{ 4 } [ T{ match { token "48cet" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } { "8" "b" } } } } l33t-variations ] unit-test
{ 21 } [ T{ match { token "a4a4aa" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } } } } l33t-variations ] unit-test
{ 21 } [ T{ match { token "4a4a44" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } } } } l33t-variations ] unit-test
{ 21 } [ T{ match { token "Aa44aA" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } } } } l33t-variations ] unit-test
{ 30 } [ T{ match { token "a44att+" } { l33t t } { sub H{ { CHAR: 4 CHAR: a } { CHAR: + CHAR: t } } } } l33t-variations ] unit-test

! ============================================================
! sequence-guesses
! ============================================================

{ 8 } [ T{ match { token "ab" } { ascending t } } sequence-guesses ] unit-test
{ 78 } [ T{ match { token "XYZ" } { ascending t } } sequence-guesses ] unit-test
{ 40 } [ T{ match { token "4567" } { ascending t } } sequence-guesses ] unit-test
{ 80 } [ T{ match { token "7654" } { ascending f } } sequence-guesses ] unit-test
{ 24 } [ T{ match { token "ZYX" } { ascending f } } sequence-guesses ] unit-test

! ============================================================
! date-guesses
! ============================================================

{ t } [
    T{ match { token "1123" } { separator "" } { year 1923 } { month 1 } { day 1 } }
    date-guesses 365 REFERENCE_YEAR 1923 - abs * =
] unit-test

{ t } [
    T{ match { token "1/1/2010" } { separator "/" } { year 2010 } { month 1 } { day 1 } }
    date-guesses 365 20 * 4 * =
] unit-test

! ============================================================
! repeat-guesses
! ============================================================

{ 200 } [
    T{ match { token "abab" } { base-token "ab" } { base-guesses 100 } { repeat-count 2 } }
    repeat-guesses
] unit-test

! ============================================================
! dictionary-guesses
! ============================================================

{ 32 } [ T{ match { token "aaaaa" } { rank 32 } { l33t f } } dictionary-guesses ] unit-test
{ 64 } [ T{ match { token "aaa" } { rank 32 } { reversed t } { l33t f } } dictionary-guesses ] unit-test

{ t } [
    T{ match { token "AAAaaa" } { rank 32 } { l33t f } }
    dictionary-guesses 32 "AAAaaa" uppercase-variations * =
] unit-test

{ t } [
    T{ match { token "aaa@@@" } { rank 32 } { l33t t } { sub H{ { "@" "a" } } } }
    dictionary-guesses
    32 T{ match { token "aaa@@@" } { l33t t } { sub H{ { "@" "a" } } } } l33t-variations * =
] unit-test

{ t } [
    T{ match { token "AaA@@@" } { rank 32 } { l33t t } { sub H{ { "@" "a" } } } }
    dictionary-guesses
    32 T{ match { token "AaA@@@" } { l33t t } { sub H{ { "@" "a" } } } } l33t-variations *
    "AaA@@@" uppercase-variations * =
] unit-test

! ============================================================
! regex-guesses
! ============================================================

{ t } [
    T{ match { token "1972" } { regex-name "recent_year" } } regex-guesses
    REFERENCE_YEAR 1972 - abs =
] unit-test

{ t } [
    T{ match { token "2005" } { regex-name "recent_year" } } regex-guesses
    REFERENCE_YEAR 2005 - abs MIN_YEAR_SPACE max =
] unit-test

{ 8031810176 } [ T{ match { token "aizocdk" } { regex-name "alpha_lower" } } regex-guesses ] unit-test
{ 916132832 } [ T{ match { token "ag7C8" } { regex-name "alphanumeric" } } regex-guesses ] unit-test
{ 1000 } [ T{ match { token "123" } { regex-name "digits" } } regex-guesses ] unit-test
{ 1185921 } [ T{ match { token "!@#$" } { regex-name "symbols" } } regex-guesses ] unit-test

! ============================================================
! spatial-guesses
! ============================================================

{ t } [
    T{ match { token "zxcvbn" } { graph "qwerty" } { turns 1 } { shifted-count 0 } }
    spatial-guesses qwerty-graph assoc-size qwerty-avg-degree * 5 * floor =
] unit-test

{ t } [
    T{ match { token "zxcvbn" } { graph "qwerty" } { turns 1 } { shifted-count 0 } }
    spatial-guesses
    T{ match { token "ZxCvbn" } { graph "qwerty" } { turns 1 } { shifted-count 2 } }
    spatial-guesses swap 6 2 nCk 6 1 nCk + * =
] unit-test

{ t } [
    T{ match { token "zxcvbn" } { graph "qwerty" } { turns 1 } { shifted-count 0 } }
    spatial-guesses
    T{ match { token "ZXCVBN" } { graph "qwerty" } { turns 1 } { shifted-count 6 } }
    spatial-guesses swap 2 * =
] unit-test

! ============================================================
! calc-average-degree
! ============================================================

{ t } [ qwerty-avg-degree 4.5 > qwerty-avg-degree 4.7 < and ] unit-test
{ t } [ keypad-avg-degree 5.0 > keypad-avg-degree 5.2 < and ] unit-test

! ============================================================
! sequence-match
! ============================================================

{ t } [ "" sequence-match empty? ] unit-test
{ t } [ "a" sequence-match empty? ] unit-test
{ t } [ "1" sequence-match empty? ] unit-test

{ t } [ "ab" sequence-match first [ ascending>> t = ] [ token>> length 2 = ] bi and ] unit-test
{ t } [ "XYZ" sequence-match first ascending>> ] unit-test
{ t } [ "4567" sequence-match first ascending>> ] unit-test
{ f } [ "7654" sequence-match first ascending>> ] unit-test
{ f } [ "ZYX" sequence-match first ascending>> ] unit-test

{ t } [ "ABC" sequence-match first [ sequence-name>> "upper" = ] [ ascending>> t = ] bi and ] unit-test
{ t } [ "CBA" sequence-match first [ sequence-name>> "upper" = ] [ ascending>> f = ] bi and ] unit-test
{ t } [ "abcd" sequence-match first [ sequence-name>> "lower" = ] [ ascending>> t = ] bi and ] unit-test
{ t } [ "dcba" sequence-match first [ sequence-name>> "lower" = ] [ ascending>> f = ] bi and ] unit-test
{ t } [ "0369" sequence-match first [ sequence-name>> "digits" = ] [ ascending>> t = ] bi and ] unit-test
{ t } [ "97531" sequence-match first [ sequence-name>> "digits" = ] [ ascending>> f = ] bi and ] unit-test

{ 3 } [ "abcbabc" sequence-match length ] unit-test
{ t } [ "!jihg!" sequence-match first [ i>> 1 = ] [ j>> 4 = ] bi and ] unit-test

! ============================================================
! spatial-match
! ============================================================

{ t } [ "" spatial-match empty? ] unit-test
{ t } [ "/" spatial-match empty? ] unit-test
{ t } [ "qw" spatial-match empty? ] unit-test

{ t } [ "zxcvbn" spatial-match [ pattern>> "spatial" = ] any? ] unit-test
{ t } [ "12345" spatial-match first [ graph>> "qwerty" = ] [ turns>> 1 = ] bi and ] unit-test
{ t } [ "@WSX" spatial-match first [ graph>> "qwerty" = ] [ shifted-count>> 4 = ] bi and ] unit-test
{ t } [ "6tfGHJ" spatial-match first [ turns>> 2 = ] [ shifted-count>> 3 = ] bi and ] unit-test

{ "keypad" } [ "159-" spatial-match first graph>> ] unit-test
{ "keypad" } [ "*84" spatial-match first graph>> ] unit-test
{ "keypad" } [ "369" spatial-match first graph>> ] unit-test
{ t } [ "/963." spatial-match [ graph>> "mac_keypad" = ] any? ] unit-test
{ "dvorak" } [ "aoEP%yIxkjq:" spatial-match first graph>> ] unit-test

! ============================================================
! repeat-match
! ============================================================

{ t } [ "" repeat-match empty? ] unit-test
{ t } [ "#" repeat-match empty? ] unit-test

{ t } [ "aaaa" repeat-match [ pattern>> "repeat" = ] any? ] unit-test
{ t } [ "aaaa" repeat-match first [ base-token>> "a" = ] [ repeat-count>> 4 = ] bi and ] unit-test

{ "a" } [ "aaaa" repeat-match first base-token>> ] unit-test
{ "Z" } [ "ZZZZ" repeat-match first base-token>> ] unit-test
{ "ab" } [ "abab" repeat-match first base-token>> ] unit-test
{ "aab" } [ "aabaab" repeat-match first base-token>> ] unit-test

{ "a" 2 } [ "aa" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test
{ "9" 3 } [ "999" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test
{ "$" 4 } [ "$$$$" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test

{ 4 } [ "BBB1111aaaaa@@@@@@" repeat-match length ] unit-test

! ============================================================
! date-match
! ============================================================

{ t } [ "13/2/1921" date-match [ pattern>> "date" = ] any? ] unit-test
{ t } [ "1991-12-20" date-match first [ year>> 1991 = ] [ month>> 12 = ] [ day>> 20 = ] tri and and ] unit-test

{ t } [ "13 2 1921" date-match [ pattern>> "date" = ] any? ] unit-test
{ t } [ "13-2-1921" date-match [ pattern>> "date" = ] any? ] unit-test
{ t } [ "13.2.1921" date-match [ pattern>> "date" = ] any? ] unit-test
{ t } [ "13\\2\\1921" date-match [ [ separator>> "\\" = ] [ year>> 1921 = ] bi and ] any? ] unit-test
{ t } [ "13_2_1921" date-match [ [ separator>> "_" = ] [ year>> 1921 = ] bi and ] any? ] unit-test

{ t } [ "8888" date-match [ year>> 1988 = ] any? ] unit-test
{ t } [ "19990101" date-match [ year>> 1999 = ] any? ] unit-test
{ t } [ "02/02/02" date-match first [ year>> 2002 = ] [ month>> 2 = ] [ day>> 2 = ] tri and and ] unit-test

! ============================================================
! regex-match
! ============================================================

{ t } [ "1922" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test
{ t } [ "2017" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test

! ============================================================
! l33t-match
! ============================================================

{ t } [ "password" ranked-dictionaries l33t-match empty? ] unit-test
{ t } [ "p4@ssword" ranked-dictionaries l33t-match [ matched-word>> "assword" = ] any? ] unit-test

! ============================================================
! omnimatch
! ============================================================

{ t } [ "" f omnimatch empty? ] unit-test
{ t } [ "password123" f omnimatch [ pattern>> "dictionary" = ] any? ] unit-test
{ t } [ "r0sebudmaelstrom11/20/91aaaa" f omnimatch [ pattern>> "dictionary" = ] any? ] unit-test
{ t } [ "r0sebudmaelstrom11/20/91aaaa" f omnimatch [ pattern>> "date" = ] any? ] unit-test
{ t } [ "r0sebudmaelstrom11/20/91aaaa" f omnimatch [ pattern>> "repeat" = ] any? ] unit-test

! ============================================================
! most-guessable-match-sequence
! ============================================================

{ "bruteforce" } [ "0123456789" V{ } most-guessable-match-sequence "sequence" of first pattern>> ] unit-test
{ "0123456789" } [ "0123456789" V{ } most-guessable-match-sequence "sequence" of first token>> ] unit-test

{ 2 } [
    "0123456789" V{ T{ match { i 0 } { j 5 } { guesses 1 } { pattern "test" } } }
    most-guessable-match-sequence "sequence" of length
] unit-test

{ 2 } [
    "0123456789" V{ T{ match { i 3 } { j 9 } { guesses 1 } { pattern "test" } } }
    most-guessable-match-sequence "sequence" of length
] unit-test

{ 3 } [
    "0123456789" V{ T{ match { i 1 } { j 8 } { guesses 1 } { pattern "test" } } }
    most-guessable-match-sequence "sequence" of length
] unit-test

{ t } [
    "0123456789" V{ T{ match { i 1 } { j 8 } { guesses 1 } { pattern "test" } } }
    most-guessable-match-sequence "sequence" of
    [ first pattern>> "bruteforce" = ] [ last pattern>> "bruteforce" = ] bi and
] unit-test

! ============================================================
! zxcvbn - scores (table-based)
! ============================================================

{ t } [
    {
        ! Weak passwords
        { "password" 0 } { "12345678" 0 } { "123456" 0 } { "qwerty" 0 }
        { "letmein" 0 } { "admin" 0 } { "welcome" 0 } { "abc123" 0 }
        { "zxcvbn" 0 } { "qwertyuiop" 0 } { "1q2w3e4r5t" 0 }
        { "" 0 } { "a" 0 }

        ! Keyboard patterns
        { "qazwsx" 0 } { "zaq12wsx" 0 } { "!QAZ2wsx" 1 } { "plm0okn" 2 }

        ! Dates
        { "19841225" 1 } { "1984-12-25" 1 } { "12251984" 1 } { "25/12/1984" 1 }

        ! Repeats
        { "aaaaaa" 0 } { "abcabcabc" 0 } { "xyzxyzxyz" 0 } { "123123123" 0 }

        ! Sequences
        { "abcdefgh" 0 } { "zyxwvuts" 0 } { "13579" 0 } { "97531" 0 }

        ! L33t
        { "p@ssw0rd" 0 } { "h4ck3r" 1 } { "4dm1n" 1 } { "l33t" 1 }

        ! Dictionary variations
        { "Password1" 0 } { "HELLO" 0 } { "sunshine123" 1 } { "Password123!" 1 }

        ! Mixed
        { "abc123xyz" 1 } { "qwerty123!" 1 } { "Pass1234word" 2 }

        ! Strong
        { "Tr0ub4dor&3" 4 } { "correcthorsebatterystaple" 4 }
        { "j7$kL9#mN2" 3 } { "xK8vQ3nR7p" 3 }
    } [ first2 [ zxcvbn "score" of ] dip = ] all?
] unit-test

! ============================================================
! zxcvbn - pattern detection (using helper)
! ============================================================

{ t } [
    {
        { "password" "dictionary" }
        { "letmein" "dictionary" }
        { "wow" "dictionary" }
        { "19841225" "date" }
        { "1984-12-25" "date" }
        { "aaaaaa" "repeat" }
        { "abcabcabc" "repeat" }
        { "abcdef" "sequence" }
        { "abc" "sequence" }
        { "xyz" "sequence" }
        { "123" "sequence" }
        { "j7$kL9#mN2" "bruteforce" }
    } [
        first2 [ zxcvbn "sequence" of ] dip
        '[ pattern>> _ = ] any?
    ] all?
] unit-test

! ============================================================
! zxcvbn - detailed match verification
! ============================================================

! password
{ 3 } [ "password" zxcvbn "guesses" of ] unit-test
{ 1 } [ "password" zxcvbn "sequence" of length ] unit-test
{ "dictionary" } [ "password" zxcvbn "sequence" of first pattern>> ] unit-test

! aaaaaa repeat
{ "a" } [ "aaaaaa" zxcvbn "sequence" of first base-token>> ] unit-test
{ 6 } [ "aaaaaa" zxcvbn "sequence" of first repeat-count>> ] unit-test

! 19841225 date
{ "date" } [ "19841225" zxcvbn "sequence" of first pattern>> ] unit-test
{ 1984 } [ "19841225" zxcvbn "sequence" of first year>> ] unit-test
{ 12 } [ "19841225" zxcvbn "sequence" of first month>> ] unit-test
{ 25 } [ "19841225" zxcvbn "sequence" of first day>> ] unit-test

! correcthorsebatterystaple
{ 4 } [ "correcthorsebatterystaple" zxcvbn "sequence" of length ] unit-test
{ "correct" } [ "correcthorsebatterystaple" zxcvbn "sequence" of first token>> ] unit-test
{ t } [ "correcthorsebatterystaple" zxcvbn "sequence" of [ pattern>> "dictionary" = ] all? ] unit-test

! Tr0ub4dor&3
{ "bruteforce" } [ "Tr0ub4dor&3" zxcvbn "sequence" of first pattern>> ] unit-test

! Reversed dictionary
{ t } [ "drowssap" zxcvbn "sequence" of first reversed>> ] unit-test

! Case insensitive
{ "dictionary" "password" } [ "PASSWORD" zxcvbn "sequence" of first [ pattern>> ] [ matched-word>> ] bi ] unit-test
{ "dictionary" "password" } [ "PaSsWoRd" zxcvbn "sequence" of first [ pattern>> ] [ matched-word>> ] bi ] unit-test

! ============================================================
! zxcvbn - feedback messages
! ============================================================

! Strong passwords have empty feedback
{ t } [
    "correcthorsebatterystaple" zxcvbn
    [ "score" of 3 >= ] [ "feedback" of not ] bi and
] unit-test

! Specific warnings
{ "This is a top-10 common password." } [ "password" zxcvbn "feedback" of "warning" of ] unit-test
{ "This is a top-100 common password." } [ "letmein" zxcvbn "feedback" of "warning" of ] unit-test
{ "This is a very common password." } [ "welcome" zxcvbn "feedback" of "warning" of ] unit-test
{ "Straight rows of keys are easy to guess." } [ ";lkjhg" zxcvbn "feedback" of "warning" of ] unit-test
{ "Sequences like \"abc\" or \"6543\" are easy to guess." } [ "abcdefgh" zxcvbn "feedback" of "warning" of ] unit-test
{ "Repeats like \"aaa\" are easy to guess." } [ "aaaaaa" zxcvbn "feedback" of "warning" of ] unit-test
{ "Repeats like \"abcabcabc\" are only slightly harder to guess than \"abc\"." } [ "abcabcabc" zxcvbn "feedback" of "warning" of ] unit-test
{ "Dates are often easy to guess." } [ "19841225" zxcvbn "feedback" of "warning" of ] unit-test

! Suggestions
{ t } [ "" zxcvbn "feedback" of "suggestions" of "Use a few words, avoid common phrases." swap member? ] unit-test
{ t } [ "p@ssw0rd" zxcvbn "feedback" of "suggestions" of "Predictable substitutions like '@' instead of 'a' don't help very much." swap member? ] unit-test

! ============================================================
! zxcvbn-with-user-inputs
! ============================================================

{ 1 } [ "john2020" { "john" "smith" } zxcvbn-with-user-inputs "score" of ] unit-test

! Max length enforcement
{ 0 } [ 72 CHAR: a <string> zxcvbn "score" of ] unit-test
[ 73 CHAR: a <string> V{ } zxcvbn-with-user-inputs ] must-fail

! Long password within limit
{ 4 } [ "weopiopdsjmkldjvoisdjfioejiojweopiopdsjmkldjvoisdjfioejioj" zxcvbn "score" of ] unit-test

! ------------------------------------------------------------
! Dictionary Matching - overlapping words
! ------------------------------------------------------------

{ t } [ "motherboard" f omnimatch [ matched-word>> "mother" = ] any? ] unit-test
{ t } [ "motherboard" f omnimatch [ matched-word>> "board" = ] any? ] unit-test

! ------------------------------------------------------------
! Dictionary Matching - case insensitive
! ------------------------------------------------------------

{ t } [ "Password" f omnimatch [ matched-word>> "password" = ] any? ] unit-test
{ t } [ "PASSWORD" f omnimatch [ matched-word>> "password" = ] any? ] unit-test

! ------------------------------------------------------------
! Reverse Dictionary Matching
! ------------------------------------------------------------

! Reversed passwords are detected with reversed>> flag
{ t } [ "drowssap" f omnimatch [ reversed>> ] any? ] unit-test
{ t } [ "DROWSSAP" f omnimatch [ reversed>> ] any? ] unit-test

! Full password zxcvbn result detects reversed
{ t } [ "drowssap" zxcvbn "sequence" of first reversed>> ] unit-test

! ------------------------------------------------------------
! L33t Matching - substitution patterns
! ------------------------------------------------------------

! Doesn't match when no relevant subs
{ t } [ "password" ranked-dictionaries l33t-match empty? ] unit-test

! Matches with single substitution
{ t } [ "p4ssword" ranked-dictionaries l33t-match [ l33t>> ] any? ] unit-test

! Matches with multiple substitutions
{ t } [ "p@ssw0rd" ranked-dictionaries l33t-match [ l33t>> ] any? ] unit-test

! ------------------------------------------------------------
! Spatial Matching - all keyboard graphs
! ------------------------------------------------------------

! QWERTY patterns
{ t } [ "qwerty" spatial-match [ graph>> "qwerty" = ] any? ] unit-test
{ t } [ "asdf" spatial-match [ graph>> "qwerty" = ] any? ] unit-test

! Dvorak patterns
{ t } [ "aoeu" spatial-match [ graph>> "dvorak" = ] any? ] unit-test

! Keypad patterns
{ t } [ "123" spatial-match [ graph>> "keypad" = ] any? ] unit-test

! Mac keypad patterns
{ t } [ "/963" spatial-match [ graph>> "mac_keypad" = ] any? ] unit-test

! Shifted keys tracked correctly
{ 0 } [ "qwerty" spatial-match first shifted-count>> ] unit-test
{ t } [ "QWERTY" spatial-match first shifted-count>> 0 > ] unit-test

! Minimum length of 3
{ t } [ "qw" spatial-match empty? ] unit-test
{ f } [ "qwe" spatial-match empty? ] unit-test

! ------------------------------------------------------------
! Sequence Matching - types and directions
! ------------------------------------------------------------

! Doesn't match single chars or two chars
{ t } [ "a" sequence-match empty? ] unit-test
{ f } [ "ab" sequence-match empty? ] unit-test

! Matches ascending
{ t } [ "abc" sequence-match first ascending>> ] unit-test
{ t } [ "rst" sequence-match first ascending>> ] unit-test
{ t } [ "456" sequence-match first ascending>> ] unit-test

! Matches descending
{ f } [ "cba" sequence-match first ascending>> ] unit-test
{ f } [ "654" sequence-match first ascending>> ] unit-test
{ f } [ "zyx" sequence-match first ascending>> ] unit-test

! Correct sequence names
{ "lower" } [ "abc" sequence-match first sequence-name>> ] unit-test
{ "upper" } [ "ABC" sequence-match first sequence-name>> ] unit-test
{ "digits" } [ "123" sequence-match first sequence-name>> ] unit-test

! Overlapping sequences
{ t } [ "abcbabc" sequence-match length 2 >= ] unit-test

! ------------------------------------------------------------
! Repeat Matching - greedy and lazy
! ------------------------------------------------------------

! Single character repeats
{ "a" 5 } [ "aaaaa" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test
{ "#" 4 } [ "####" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test

! Multi-character repeats
{ "ab" 2 } [ "abab" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test
{ "abc" 3 } [ "abcabcabc" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test

! Repeat detection prefers shorter base tokens
{ "aab" 2 } [ "aabaab" repeat-match first [ base-token>> ] [ repeat-count>> ] bi ] unit-test

! Mixed repeats in one password
{ t } [ "aaaBBBccc" repeat-match length 3 = ] unit-test

! ------------------------------------------------------------
! Regex Matching - recent years
! ------------------------------------------------------------

! Years inside recent year range
{ t } [ "1922" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test
{ t } [ "2017" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test
{ t } [ "2000" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test
{ t } [ "1999" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test

! Years outside recent year range
{ f } [ "1899" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test

! ------------------------------------------------------------
! Date Matching - formats and separators
! ------------------------------------------------------------

! Various date formats without separators
{ t } [ "19861231" date-match [ year>> 1986 = ] any? ] unit-test
{ t } [ "12311986" date-match [ year>> 1986 = ] any? ] unit-test

! With separators
{ t } [ "12/31/1986" date-match [ separator>> "/" = ] any? ] unit-test
{ t } [ "12-31-1986" date-match [ separator>> "-" = ] any? ] unit-test
{ t } [ "12.31.1986" date-match [ separator>> "." = ] any? ] unit-test
{ t } [ "12 31 1986" date-match [ separator>> " " = ] any? ] unit-test

! Two-digit years
{ t } [ "12/31/86" date-match [ year>> 1986 = ] any? ] unit-test

! Year closest to reference year is preferred
{ t } [ "111504" date-match [ year>> 2004 = ] any? ] unit-test

! Validates month 1-12
{ f } [ "13/01/2000" date-match [ month>> 13 = ] any? ] unit-test

! Validates day 1-31
{ f } [ "01/32/2000" date-match [ day>> 32 = ] any? ] unit-test

! ------------------------------------------------------------
! L33t Variations - comprehensive
! ------------------------------------------------------------

! No l33t - returns 1
{ 1 } [ T{ match { token "password" } { l33t f } { sub H{ } } } l33t-variations ] unit-test

! Single sub - 2x
{ 2 } [ T{ match { token "p4ssword" } { l33t t } { sub H{ { "4" "a" } } } } l33t-variations ] unit-test

! Two subs - 4x
{ 4 } [ T{ match { token "p4ssw0rd" } { l33t t } { sub H{ { "4" "a" } { "0" "o" } } } } l33t-variations ] unit-test

! ------------------------------------------------------------
! Bruteforce Pattern - unmatched characters
! ------------------------------------------------------------

! Pure symbols without keyboard adjacency become bruteforce
{ "bruteforce" } [ "!@#" zxcvbn "sequence" of first pattern>> ] unit-test

! Random strings should contain bruteforce patterns
{ t } [ "xK8vQ3nR7p" zxcvbn "sequence" of [ pattern>> "bruteforce" = ] any? ] unit-test

! Single uncommon characters are bruteforce
{ "bruteforce" } [ "~" zxcvbn "sequence" of first pattern>> ] unit-test

! ------------------------------------------------------------
! Empty Password Handling
! ------------------------------------------------------------

{ 0 } [ "" zxcvbn "score" of ] unit-test
{ t } [ "" zxcvbn "guesses" of 1 = ] unit-test
{ t } [ "" zxcvbn "sequence" of empty? ] unit-test

! ------------------------------------------------------------
! User inputs - custom dictionary
! ------------------------------------------------------------

! Username in user inputs should be detected
{ t } [
    "johndoe2020" { "johndoe" } zxcvbn-with-user-inputs "sequence" of
    [ [ dictionary-name>> "user_inputs" = ] [ matched-word>> "johndoe" = ] bi and ] any?
] unit-test

! User inputs are case-insensitive
{ t } [
    "JOHNDOE2020" { "johndoe" } zxcvbn-with-user-inputs "sequence" of
    [ dictionary-name>> "user_inputs" = ] any?
] unit-test

! User inputs lower password score
{ t } [
    "johndoe" { "johndoe" } zxcvbn-with-user-inputs "score" of
    "johndoe" zxcvbn "score" of <=
] unit-test

! ------------------------------------------------------------
! Feedback - specific warnings
! ------------------------------------------------------------

! Spatial pattern feedback
{ t } [ "qwerty" zxcvbn "feedback" of "warning" of length 0 > ] unit-test

! Repeat pattern feedback
{ t } [ "aaaaaa" zxcvbn "feedback" of "warning" of "Repeats" swap subseq? ] unit-test

! Sequence pattern feedback
{ t } [ "abcdefgh" zxcvbn "feedback" of "warning" of "Sequences" swap subseq? ] unit-test

! Date pattern feedback
{ t } [ "19841225" zxcvbn "feedback" of "warning" of "Dates" swap subseq? ] unit-test

! ------------------------------------------------------------
! Crack Times - structure and reasonableness
! ------------------------------------------------------------

! All crack time fields present
{ t } [
    "password" zxcvbn "attack" of {
        "online_throttling_100_per_hour"
        "online_no_throttling_10_per_second"
        "offline_slow_hashing_1e4_per_second"
        "offline_fast_hashing_1e10_per_second"
    } [ swap key? ] with all?
] unit-test

! Online throttled is slowest
{ t } [
    "password" zxcvbn "attack" of
    [ "online_throttling_100_per_hour" of ]
    [ "offline_fast_hashing_1e10_per_second" of ] bi >
] unit-test

! Stronger passwords have longer crack times
{ t } [
    "correcthorsebatterystaple" "password"
    [ zxcvbn "attack" of "offline_fast_hashing_1e10_per_second" of ] bi@ >
] unit-test

! ------------------------------------------------------------
! Pattern combinations
! ------------------------------------------------------------

! Complex password with multiple patterns
{ t } [ "r0sebudmaelstrom11/20/91aaaa" zxcvbn "sequence" of length 3 >= ] unit-test

! Password with dictionary + date
{ t } [ "password1984" zxcvbn "sequence" of [ pattern>> "dictionary" = ] any? ] unit-test

! Password with dictionary/spatial + repeat
{ t } [
    "qwertyaaaa" zxcvbn "sequence" of
    [ [ pattern>> { "spatial" "dictionary" } member? ] any? ]
    [ [ pattern>> "repeat" = ] any? ] bi and
] unit-test

! ------------------------------------------------------------
! Well-known password scores (compatibility tests)
! ------------------------------------------------------------

! Famous XKCD password
{ 4 } [ "correcthorsebatterystaple" zxcvbn "score" of ] unit-test

! Top passwords should be score 0
{ 0 } [ "123456" zxcvbn "score" of ] unit-test
{ 0 } [ "password" zxcvbn "score" of ] unit-test
{ 0 } [ "qwerty" zxcvbn "score" of ] unit-test
{ 0 } [ "letmein" zxcvbn "score" of ] unit-test
{ 0 } [ "football" zxcvbn "score" of ] unit-test
{ 0 } [ "iloveyou" zxcvbn "score" of ] unit-test

! Common patterns should be weak
{ t } [ "abc123" zxcvbn "score" of 2 < ] unit-test
{ t } [ "123abc" zxcvbn "score" of 2 < ] unit-test

! ------------------------------------------------------------
! Date edge cases
! ------------------------------------------------------------

! Year range validation (1000-2050)
{ f } [ "01/01/0999" date-match [ year>> 999 = ] any? ] unit-test
{ f } [ "01/01/2051" date-match [ year>> 2051 = ] any? ] unit-test
{ t } [ "01/01/2050" date-match [ year>> 2050 = ] any? ] unit-test
{ t } [ "01/01/1000" date-match [ year>> 1000 = ] any? ] unit-test

! Multiple date interpretations - closest to reference year preferred
{ t } [ "02/02/02" date-match [ year>> 2000 >= ] any? ] unit-test

! ------------------------------------------------------------
! Sequence guesses
! ------------------------------------------------------------

! Descending sequences have 2x multiplier (when same start char)
{ t } [ T{ match { token "zyx" } { ascending f } } sequence-guesses
        T{ match { token "zab" } { ascending t } } sequence-guesses > ] unit-test

! First character affects guesses - 'a' and 'z' have lower base (4)
{ t } [ T{ match { token "abc" } { ascending t } } sequence-guesses
        T{ match { token "rst" } { ascending t } } sequence-guesses < ] unit-test

! Longer sequences have more guesses
{ t } [ T{ match { token "abcd" } { ascending t } } sequence-guesses
        T{ match { token "abc" } { ascending t } } sequence-guesses > ] unit-test

! ------------------------------------------------------------
! Date guesses
! ------------------------------------------------------------

! With separator = 4x more guesses
{ t } [ T{ match { token "1/1/2000" } { separator "/" } { year 2000 } { month 1 } { day 1 } } date-guesses
        T{ match { token "112000" } { separator "" } { year 2000 } { month 1 } { day 1 } } date-guesses
        4 * = ] unit-test

! ------------------------------------------------------------
! Spatial guesses
! ------------------------------------------------------------

! Shifted keys add complexity
{ t } [ T{ match { token "QWERTY" } { graph "qwerty" } { turns 1 } { shifted-count 6 } } spatial-guesses
        T{ match { token "qwerty" } { graph "qwerty" } { turns 1 } { shifted-count 0 } } spatial-guesses > ] unit-test

! More turns add complexity
{ t } [ T{ match { token "qweasd" } { graph "qwerty" } { turns 3 } { shifted-count 0 } } spatial-guesses
        T{ match { token "qwerty" } { graph "qwerty" } { turns 1 } { shifted-count 0 } } spatial-guesses > ] unit-test

! ------------------------------------------------------------
! Result consistency
! ------------------------------------------------------------

! password field matches input
{ "testpassword" } [ "testpassword" zxcvbn "password" of ] unit-test

! score is between 0-4
{ t } [ "anything" zxcvbn "score" of [ 0 >= ] [ 4 <= ] bi and ] unit-test

! guesses is positive
{ t } [ "test" zxcvbn "guesses" of 0 > ] unit-test

! sequence positions are valid (i <= j)
{ t } [ "password123" zxcvbn "sequence" of [ [ i>> ] [ j>> ] bi <= ] all? ] unit-test

! tokens cover matched positions
{ t } [ "password" zxcvbn "sequence" of first [ [ j>> ] [ i>> ] bi - 1 + ] [ token>> length ] bi = ] unit-test

! ------------------------------------------------------------
! Embedded pattern tests
! ------------------------------------------------------------

! Spatial pattern embedded in non-spatial chars
{ t } [ "rz!6tfGHJ%z" spatial-match [ token>> "6tfGHJ" = ] any? ] unit-test

! Sequence embedded in other chars
{ t } [ "!jihg!" sequence-match [ token>> "jihg" = ] any? ] unit-test
{ t } [ "22abcd22" sequence-match [ token>> "abcd" = ] any? ] unit-test

! Repeat pattern embedded
{ t } [ "xx&&&&&yy" repeat-match [ token>> "&&&&&" = ] any? ] unit-test

! Date embedded in password
{ t } [ "a1/1/91!" date-match [ token>> "1/1/91" = ] any? ] unit-test
{ t } [ "ab1/1/91!" date-match [ token>> "1/1/91" = ] any? ] unit-test

! ------------------------------------------------------------
! Overlapping date patterns
! ------------------------------------------------------------

{ t } [ "12/20/1991.12.20" date-match [ separator>> "/" = ] any? ] unit-test
{ t } [ "12/20/1991.12.20" date-match [ separator>> "." = ] any? ] unit-test
{ t } [ "12/20/1991.12.20" date-match length 2 >= ] unit-test

! Date padded by non-date digits
{ t } [ "912/20/919" date-match [ token>> "12/20/91" = ] any? ] unit-test

! ------------------------------------------------------------
! L33t matching edge cases
! ------------------------------------------------------------

! Doesn't match single-character l33ted words
{ t } [ "4 1 @" ranked-dictionaries l33t-match empty? ] unit-test

! Multiple l33t patterns in complex password
{ t } [ "@a(go{G0" ranked-dictionaries l33t-match length 0 >= ] unit-test

! ------------------------------------------------------------
! Spatial matching - surrounded patterns
! ------------------------------------------------------------

{ t } [ "rz!6tfGHJ%z" spatial-match first [ turns>> 2 = ] [ shifted-count>> 3 = ] bi and ] unit-test

! Dvorak complex pattern
{ t } [ ";qoaOQ:Aoq;a" spatial-match [ graph>> "dvorak" = ] any? ] unit-test

! ------------------------------------------------------------
! Repeat matching - multiple adjacent repeats
! ------------------------------------------------------------

{ t } [ "BBB1111aaaaa@@@@@@" repeat-match [ base-token>> "B" = ] any? ] unit-test
{ t } [ "BBB1111aaaaa@@@@@@" repeat-match [ base-token>> "1" = ] any? ] unit-test
{ t } [ "BBB1111aaaaa@@@@@@" repeat-match [ base-token>> "a" = ] any? ] unit-test
{ t } [ "BBB1111aaaaa@@@@@@" repeat-match [ base-token>> "@" = ] any? ] unit-test

! Non-adjacent repeats in complex password
{ t } [ "2818BBBbzsdf1111@*&@!aaaaaEUDA@@@@@@1729" repeat-match length 4 >= ] unit-test

! Multi-character repeat prefers shorter base
{ "ab" } [ "abababab" repeat-match first base-token>> ] unit-test

! ------------------------------------------------------------
! Dictionary matching - user inputs with ranks
! ------------------------------------------------------------

! User inputs get rank 1 when not in other dictionaries
{ t } [
    "myjohndoe2020" { "myjohndoe" } zxcvbn-with-user-inputs "sequence" of
    [ [ dictionary-name>> "user_inputs" = ] [ rank>> 1 = ] bi and ] any?
] unit-test

! ------------------------------------------------------------
! Repeat guesses - from reference implementations
! ------------------------------------------------------------

! batterystaple repeated 3 times
{ t } [
    "batterystaplebatterystaplebatterystaple" repeat-match
    [ [ base-token>> "batterystaple" = ] [ repeat-count>> 3 = ] bi and ] any?
] unit-test

! ------------------------------------------------------------
! More dictionary matching tests
! ------------------------------------------------------------

{ t } [ "wow" f omnimatch [ dictionary-name>> "us_tv_and_film" = ] any? ] unit-test

! ------------------------------------------------------------
! Spatial matching - all keyboard types comprehensively
! ------------------------------------------------------------

! QWERTY specific patterns
{ t } [ "12345" spatial-match [ [ graph>> "qwerty" = ] [ turns>> 1 = ] bi and ] any? ] unit-test
{ t } [ "@WSX" spatial-match [ graph>> "qwerty" = ] any? ] unit-test
{ t } [ "hGFd" spatial-match [ graph>> "qwerty" = ] any? ] unit-test
{ t } [ "/;p09876yhn" spatial-match [ graph>> "qwerty" = ] any? ] unit-test
{ t } [ "Xdr%" spatial-match [ graph>> "qwerty" = ] any? ] unit-test

! Keypad specific
{ t } [ "/8520" spatial-match [ graph>> "keypad" = ] any? ] unit-test

! Mac keypad specific
{ t } [ "*-632.0214" spatial-match [ graph>> "mac_keypad" = ] any? ] unit-test

! ------------------------------------------------------------
! Sequence matching - comprehensive direction tests
! ------------------------------------------------------------

! Uppercase descending
{ t } [ "PQR" sequence-match first ascending>> ] unit-test
{ t } [ "RQP" sequence-match first ascending>> not ] unit-test
{ t } [ "XYZ" sequence-match first ascending>> ] unit-test
{ t } [ "ZYX" sequence-match first ascending>> not ] unit-test

! Digit sequences with step > 1
{ t } [ "0369" sequence-match first ascending>> ] unit-test
{ t } [ "97531" sequence-match first ascending>> not ] unit-test

! ------------------------------------------------------------
! Date matching - two-digit year handling
! ------------------------------------------------------------

{ t } [ "111504" date-match [ [ year>> 2004 = ] [ month>> 11 = ] [ day>> 15 = ] tri and and ] any? ] unit-test

! ------------------------------------------------------------
! Recent year regex - boundary tests
! ------------------------------------------------------------

{ t } [ "1900" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test
{ t } [ "2019" regex-match [ regex-name>> "recent_year" = ] any? ] unit-test

! ------------------------------------------------------------
! Complex password integration test
! Verifies all pattern types are detected in correct positions
! ------------------------------------------------------------

! Dictionary at position 0-6 (r0sebud -> rosebud)
{ t } [
    "r0sebudmaelstrom11/20/91aaaa" f omnimatch
    [ [ i>> 0 = ] [ pattern>> "dictionary" = ] bi and ] any?
] unit-test

! Dictionary at position 7-15 (maelstrom)
{ t } [
    "r0sebudmaelstrom11/20/91aaaa" f omnimatch
    [ [ i>> 7 = ] [ matched-word>> "maelstrom" = ] bi and ] any?
] unit-test

! Date at position 16-23 (11/20/91)
{ t } [
    "r0sebudmaelstrom11/20/91aaaa" f omnimatch
    [ [ pattern>> "date" = ] [ token>> "11/20/91" = ] bi and ] any?
] unit-test

! Repeat at position 24-27 (aaaa)
{ t } [
    "r0sebudmaelstrom11/20/91aaaa" f omnimatch
    [ [ pattern>> "repeat" = ] [ token>> "aaaa" = ] bi and ] any?
] unit-test

! ------------------------------------------------------------
! Score distribution validation
! ------------------------------------------------------------

! Top passwords from list should be score 0
{ 0 } [ "dragon" zxcvbn "score" of ] unit-test
{ 0 } [ "baseball" zxcvbn "score" of ] unit-test
{ 0 } [ "monkey" zxcvbn "score" of ] unit-test

! Medium strength passwords
{ t } [ "trustno1" zxcvbn "score" of 2 < ] unit-test
{ t } [ "sunshine" zxcvbn "score" of 2 < ] unit-test

! ------------------------------------------------------------
! Empty and minimal passwords
! ------------------------------------------------------------

! Single character passwords
{ 0 } [ "a" zxcvbn "score" of ] unit-test
{ 0 } [ "1" zxcvbn "score" of ] unit-test
{ 0 } [ "!" zxcvbn "score" of ] unit-test

! Two character passwords
{ 0 } [ "ab" zxcvbn "score" of ] unit-test
{ 0 } [ "12" zxcvbn "score" of ] unit-test

! ------------------------------------------------------------
! L33t suggestion feedback
! ------------------------------------------------------------

{ t } [ "4dm1n" zxcvbn "feedback" of "suggestions" of
        [ "Predictable substitutions" swap subseq? ] any? ] unit-test

! ------------------------------------------------------------
! Capitalization suggestion feedback
! ------------------------------------------------------------

{ t } [
    "PASSWORD" zxcvbn "feedback" of "suggestions" of
    [ "All-uppercase" swap subseq? ] any?
] unit-test

{ t } [
    "Password" zxcvbn "feedback" of "suggestions" of
    [ "Capitalization" swap subseq? ] any?
] unit-test

! ------------------------------------------------------------
! Reversed word suggestion feedback
! ------------------------------------------------------------

{ t } [
    "drowssap" zxcvbn "feedback" of "suggestions" of
    [ "Reversed" swap subseq? ] any?
] unit-test

! ------------------------------------------------------------
! Unicode/International character tests
! ------------------------------------------------------------

! Unicode password should not crash and return valid result
{ t } [ "pÄssword junkiË" zxcvbn "score" of [ 0 >= ] [ 4 <= ] bi and ] unit-test
{ t } [ "pÄssword junkiË" zxcvbn "guesses" of 0 > ] unit-test

! Unicode characters treated as bruteforce when not in dictionary
{ t } [ "pÄssword junkiË" zxcvbn "sequence" of [ pattern>> "bruteforce" = ] any? ] unit-test

! Partial dictionary match still works with unicode
{ t } [ "pÄssword junkiË" zxcvbn "sequence" of [ matched-word>> "sword" = ] any? ] unit-test

! Cyrillic user inputs work correctly
{ t } [ "Фамилия2020" { "Фамилия" } zxcvbn-with-user-inputs "sequence" of
        [ dictionary-name>> "user_inputs" = ] any? ] unit-test

! Cyrillic matched case-insensitively
{ t } [ "Фамилия2020" { "Фамилия" } zxcvbn-with-user-inputs "sequence" of
        [ matched-word>> "фамилия" = ] any? ] unit-test

! Pure unicode password doesn't crash
{ t } [ "日本語パスワード" zxcvbn "score" of [ 0 >= ] [ 4 <= ] bi and ] unit-test

! Mixed unicode and ASCII
{ t } [ "password密码" zxcvbn "sequence" of [ pattern>> "dictionary" = ] any? ] unit-test

! Emoji in password (should be bruteforce)
{ t } [ "pass🔒word" zxcvbn "score" of [ 0 >= ] [ 4 <= ] bi and ] unit-test

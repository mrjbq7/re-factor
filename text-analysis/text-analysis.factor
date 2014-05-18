! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators formatting kernel literals math
math.order multiline regexp sequences sequences.extras sets
splitting unicode.case unicode.categories ;

IN: text-analysis

<PRIVATE

: split-paragraphs ( str -- seq )
    R/ (?:\n[\r\t ]*)+/ re-split ;

CONSTANT: ABBREVIATIONS {
    "jr" "mr" "mrs" "ms" "dr" "prof" "sr" "sen" "rep" "rev"
    "gov" "atty" "supt" "det" "rev" "col','gen" "lt" "cmdr"
    "adm" "capt" "sgt" "cpl" "maj" ! titles

    "dept" "univ" "uni" "assn" "bros" "inc" "ltd" "co" "corp"
    "plc" ! entities

    "jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct"
    "nov" "dec" "sept" ! months

    "mon" "tue" "wed" "thu" "fri" "sat" "sun" ! days

    "vs" "etc" "no" "esp" "cf" ! misc

    "ave" "bld" "blvd" "cl" "ct" "cres" "dr" "rd" "st" ! streets
}

: split-sentences ( str -- seq )

    ! Mark end of sentences with EOS marker
    R/ ((?:[\.?!]|[\r\n]+)(?:\"|\'|\)|\]|\})?)(\s+)/
    [ [ ".?!\r\n\"')]}" member? not ] cut-when "\x01" glue ]
    re-replace-with

    ! Fix ellipsis marks
    $[ "(\\.\\.\\.*)\x01" <regexp> ] [ but-last-slice ]
    re-replace-with

    ! Fix e.g, i.e. marks
    $[
        "(?:\\s(?:(?:(?:\\w\\.){2,}\\w?)|(?:\\w\\.\\w)))\x01(\\s+[a-z0-9])"
        <regexp>
    ] [ [ 1 = ] cut-when append ] re-replace-with

    ! Fix abbreviations
    $[
        ABBREVIATIONS "|" join "(" ")\\.\x01" surround
        "i" <optioned-regexp>
    ] [ CHAR: . over index head ] re-replace-with

    ! Split on EOS marker
    "\x01" split [ [ blank? ] trim ] map harvest ;

CONSTANT: sub-syllable {
    R/ [^aeiou]e$/ ! give, love, bone, done, ride ...
    R/ [aeiou](?:([cfghklmnprsvwz])\1?|ck|sh|[rt]ch)e[ds]$/
    ! (passive) past participles and 3rd person sing present verbs:
    ! bared, liked, called, tricked, bashed, matched

    R/ .e(?:ly|less(?:ly)?|ness?|ful(?:ly)?|ments?)$/
    ! nominal, adjectival and adverbial derivatives from -e$ roots:
    ! absolutely, nicely, likeness, basement, hopeless
    ! hopeful, tastefully, wasteful

    R/ ion/ ! action, diction, fiction
    R/ [ct]ia[nl]/ ! special(ly), initial, physician, christian
    R/ [^cx]iou/ ! illustrious, NOT spacious, gracious, anxious, noxious
    R/ sia$/ ! amnesia, polynesia
    R/ .gue$/ ! dialogue, intrigue, colleague
}

CONSTANT: add-syllable {
    R/ i[aiou]/ ! alias, science, phobia
    R/ [dls]ien/ ! salient, gradient, transient
    R/ [aeiouym]ble$/ ! -Vble, plus -mble
    R/ [aeiou]{3}/ ! agreeable
    R/ ^mc/ ! mcwhatever
    R/ ism$/ ! sexism, racism
    R/ (?:([^aeiouy])\1|ck|mp|ng)le$/ ! bubble, cattle, cackle, sample, angle
    R/ dnt$/ ! couldn/t
    R/ [aeiou]y[aeiou]/ ! annoying, layer
}

: syllables ( str -- n )
    dup length 1 = [ drop 1 ] [
        >lower CHAR: . swap remove
        [ R/ [aeiouy]+/ count-matches ]
        [ sub-syllable [ matches? ] with count - ]
        [ add-syllable [ matches? ] with count + ] tri
        1 max
    ] if ;

: split-words ( str -- words )
    R/ \b([a-z][a-z\-']*)\b/i all-matching-subseqs ;

TUPLE: text-analysis #paragraphs #sentences #chars #words
#syllables #complex-words #unique-words ;

: <text-analysis> ( str -- text-analysis )
    {
        [ split-paragraphs length ]
        [ split-sentences length ]
        [ length ]
        [ split-words ]
    } cleave {
        [ length ]
        [
            [ 0 0 ] dip [
                [ syllables ] [ "-" member? not ] bi
                over 2 > and 1 0 ? [ + ] bi-curry@ bi*
            ] each
        ]
        [ members length ]
    } cleave text-analysis boa ;

: syllables-per-word ( text-analysis -- n )
    [ #syllables>> ] [ #words>> ] bi / ;

: words-per-sentence ( text-analysis -- n )
    [ #words>> ] [ #sentences>> ] bi / ;

: percent-complex-words ( text-analysis -- n )
    [ #complex-words>> ] [ #words>> ] bi / 100 * ;

: flesch-kincaid ( text-analysis -- n )
    [ syllables-per-word 11.8 * ]
    [ words-per-sentence 0.39 * ] bi + 15.59 - ;

: flesch ( text-analysis -- n )
    206.835 swap
    [ words-per-sentence 1.015 * - ]
    [ syllables-per-word 84.6 * - ] bi ;

: gunning-fog ( text-analysis -- n )
    [ words-per-sentence ] [ percent-complex-words ] bi + 0.4 * ;

STRING: text-report-format
Number of paragraphs           %d
Number of sentences            %d
Number of words                %d
Number of characters           %d

Average words per sentence     %.2f
Average syllables per word     %.2f

Flesch score                   %2.2f
Flesh-Kincaid grade level      %2.2f
Gunning fog index              %2.2f

;

PRIVATE>

: analyze-text. ( str -- )
    <text-analysis> {
        [ #paragraphs>> ]
        [ #sentences>> ]
        [ #words>> ]
        [ #chars>> ]
        [ words-per-sentence ]
        [ syllables-per-word ]
        [ flesch ]
        [ flesch-kincaid ]
        [ gunning-fog ]
    } cleave text-report-format printf ;
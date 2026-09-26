USING: accessors assocs geekcode.private html.parser io.streams.string
kernel multiline sequences sets splitting tools.test ;
IN: geekcode

{
    {
        {
            "Dress"
            "My t-shirts go a step further and have a trendy political message on them."
        }
        { "Age" "20-24" }
        {
            "Perl"
            "I know of Perl. I like Perl. I just haven't learned much Perl, but it is on my agenda."
        }
        {
            "Linux"
            "I use Linux ALMOST exclusively on my system. I've given up trying to achieve Linux.God status, but welcome the OS as a replacement for DOS. I only boot to DOS to play games."
        }
        { "Emacs" "Emacs sucks! pico forever!!!" }
        {
            "USENET News"
            "I read so many newsgroups that the next batch of news comes in before I finish reading the last batch, and I have to read for about 2 hours straight before I'm caught up on the morning's news. Then there's the afternoon..."
        }
        { "USENET Oracle" "I have been incarnated at least once." }
        { "Kibo" "I've gotten mail from Kibo" }
        {
            "Microsoft Windows"
            "Windows has set back the computing industry by at least 10 years. Bill Gates should be drawn, quartered, hung, shot, poisoned, disembowelled, and then REALLY hurt."
        }
        { "OS/2" "Tried it, didn't like it." }
        {
            "Macintosh"
            "A Mac has it's uses and I use it quite often."
        }
        {
            "VMS"
            "I would rather smash my head repeatedly into a brick wall than suffer the agony of working with VMS. It's reminiscent of a dead and decaying pile of moose droppings. Unix rules the universe."
        }
        {
            "Cypherpunks"
            "I am on the cypherpunks mailing list and active around Usenet. I never miss an opportunity to talk about the evils of Clipper and ITAR and the NSA. Orwell's 1984 is more than a story, it is a warning to our's and future generations. I'm a member of the EFF."
        }
        {
            "PGP"
            "I have the most recent version and use it regularly"
        }
        {
            "Star Trek"
            "Maybe it is just me, but I have no idea what the big deal with Star Trek is. Perhaps I'm missing something but I just think it is bad drama."
        }
        {
            "Babylon 5"
            "I am a True Worshipper of the Church of Joe who lives eats breathes and thinks Babylon 5, and has Evil thoughts about stealing Joe's videotape archives just to see episodes earlier. I am planning to break into the bank and steal the triple-encoded synopsis of the 5-year arc."
        }
        {
            "X-Files"
            "This is one of the better shows I've seen. I wish I'd taped everything from the start at SP, because I'm wearing out my EP tapes. I'll periodically debate online. I've Converted at least 5 people. I've gotten a YAXA."
        }
        { "Television" "I watch some tv every day." }
        {
            "Books"
            "I enjoy reading, but don't get the time very often."
        }
        { "Dilbert" "I am a Dilbert prototype" }
        {
            "DOOM!"
            "I crank out PWAD files daily, complete with new monsters, weaponry, sounds and maps. I'm a DOOM God. I can solve the original maps in nightmare mode with my eyes closed."
        }
        { "The Geek Code" "I am Robert Hayden" }
        { "Education" "Got a Bachelors degree" }
        {
            "Housing"
            "Friends come over to visit every once in a while to talk about Geek things. There is a place for them to sit."
        }
        {
            "Relationships"
            "People just aren't interested in dating me."
        }
    }
} [
    [[
    -----BEGIN GEEK CODE BLOCK-----
    Version: 3.1
    d-- a-- P+ L++ E---- N+++ o+ K+++ w---
    O- M+ V-- Y++ PGP++ t- 5+++ X++ tv+ b+ DI+++ D+++
    G+++++ e++ h r--
    ------END GEEK CODE BLOCK------
    ]] geekcode
] unit-test


! Every published table entry must remain available without network access.
{ 34 303 } [ geekcode-spec length code-table assoc-size ] unit-test
{ t } [
    code-table [ [ geekcode first ] dip = ] assoc-all?
] unit-test

! Headings and term/definition boundaries, rather than positional offsets.
{ { { "Books" H{ { "b" "Read books & magazines." } } } } } [
    [[ <html><h1>Introduction</h1><p>Not a rating.</p>
    <h2><em>Books</em></h2><dl><dt><b>b</b></dt>
    <dd> Read books &amp;
 magazines. </dd></dl></html> ]]
    parse-html parse-spec
] unit-test

{ { } } [ "" geekcode ] unit-test
{ { } } [ " \t\r\n " geekcode-unknown ] unit-test
{ t } [ "d-- a--" geekcode "d--\t\r\na--" geekcode = ] unit-test
{ { { "Type" "Geek of Education; Geek of Jurisprudence (Law)" } } } [
    "GED/J" geekcode
] unit-test
{ { "GCS/invalid" } } [ "GCS/invalid" geekcode-unknown ] unit-test

! Case is significant: W is the Web, w is Windows.
{ { "World Wide Web" "Microsoft Windows" } } [
    "W+ w+" geekcode [ first ] map
] unit-test
{ { "Television" "Star Trek" "Dilbert" "DOOM!" "PGP" "Perl" } } [
    "tv t DI D PGP P" geekcode [ first ] map
] unit-test

! Category-specific meanings take precedence over generic variables.
{ "immortal" } [ "a?" geekcode first second ] unit-test
{ t } [ "!d" geekcode first second "!d" lookup-code second = ] unit-test
{ "I have no knowledge of this category." } [ "E?" geekcode first second ] unit-test
{ "I refuse to participate in this category." } [ "!E" geekcode first second ] unit-test

{ t } [
    "C++(++++)" geekcode first second
    "C++" lookup-code second "C++++" lookup-code second "Range: " prepend " " glue =
] unit-test
{ t } [
    "W+(-)" geekcode first second
    "W+" lookup-code second "W-" lookup-code second "Range: " prepend " " glue =
] unit-test
{ t } [
    "C++>++++" geekcode first second
    "C++" lookup-code second "C++++" lookup-code second "Goal: " prepend " " glue =
] unit-test
{ t } [
    "L++$" geekcode first second
    "L++" lookup-code second " I do this for a living." append =
] unit-test
{ t } [
    "t++@" geekcode first second
    "t++" lookup-code second " This rating varies with circumstances." append =
] unit-test
{ t } [
    "PS++>$" geekcode first second
    "PS++" lookup-code second " I would like to do this for a living." append =
] unit-test
{ t } [ "C++@$" geekcode "C++$@" geekcode = ] unit-test
{ t } [ "C++()" geekcode first second "C" lookup-code second tail? ] unit-test
{ t } [
    "C++(+++)>++++$" geekcode first second
    " I do this for a living." tail?
] unit-test

! Decoding a modified rating must not mutate the cached plain rating.
{ t } [
    "L++" geekcode "L++$" geekcode drop "L++" geekcode =
] unit-test

! Unknown or partly invalid tokens are preserved whole, in input order.
{ { "unknown" } } [
    "unknown d-- s:++>: a-- ULU++ y++**" geekcode-unknown
] unit-test
{ t } [
    {
        "C++(" "C++)" "C++(oops)" "C++((+))" "C++>"
        "C++>oops" "C++>+++>++++" "C++@@" "C++$$"
        "C++?" "!C++" "G!(+++)" "G!>++++" "!E>GCS" "GCS/" "GCS//MU" "GCS/invalid"
    } [ dup geekcode-unknown first = ] all?
] unit-test

STRING: hayden-code
-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GED/J d-- s:++>: a-- C++(++++) ULU++ P+ L++ E---- W+(-) N+++ o+ K+++ w---
O- M+ V-- PS++>$ PE++>$ Y++ PGP++ t- 5+++ X++ R+++>$ tv+ b+ DI+++ D+++
G+++++ e++ h r-- y++**
------END GEEK CODE BLOCK------
;

{ 34 } [ hayden-code geekcode length ] unit-test
{ { } } [ hayden-code geekcode-unknown ] unit-test
{ t } [
    hayden-code geekcode hayden-code "3.12" "3.1" replace geekcode =
] unit-test
[ "Version: 6.0\nGCS" geekcode ] [ unsupported-geekcode-version? ] must-fail-with

! The display API also reports what it could not decode.
{ t } [
    [ "e++ unknown" geekcode. ] with-string-writer
    "Unrecognized codes: unknown\n" tail?
] unit-test


! Shape components are independent; goals reuse the normal modifier path.
{ "Height: average; build: heavy. Goal: I'm an average geek" } [
    "s:++>:" geekcode first second
] unit-test
{ "Height: tall; build: very thin." } [
    "s++:--" geekcode first second
] unit-test
{ t } [
    { "s+++:" "s:+++" "s---:" "s:---" "s+:-" "s-:+" }
    [ geekcode-unknown empty? ] all?
] unit-test

! Unix flavor letters preserve the shared U rating, including modifiers.
{ t } [
    "ULU++" geekcode first second
    "U++" lookup-code second " Systems: Linux, Ultrix." append =
] unit-test
{ t } [
    "UL++$" geekcode first second
    "U++" lookup-code second " Systems: Linux. I do this for a living." append =
] unit-test
{ t } [
    "U*++>+++" geekcode first second
    "U++" lookup-code second " Systems: other Unix. Goal: " append
    "U+++" lookup-code second append " Systems: other Unix." append =
] unit-test
{ t } [
    "UBLUAVHIOSCX*++++" geekcode-unknown empty?
] unit-test

! Gender is an alias for the z table; * and ** add their own descriptions.
{ t } [
    "y++**" geekcode first second
    "z++" lookup-code second "z**" lookup-code second " " glue
    " Male." append =
] unit-test
{ t } [
    "x+*" geekcode first second
    "z+" lookup-code second "z*" lookup-code second " " glue
    " Female." append =
] unit-test
{ t } [
    "z++**" geekcode first second
    "z++" lookup-code second "z**" lookup-code second " " glue
    " Gender undisclosed." append =
] unit-test
{ t } [
    "!y+" geekcode first second
    "!z+" lookup-code second " Male." append =
] unit-test
{ t } [
    "x?" geekcode first second
    "z?" lookup-code second " Female." append =
] unit-test
{ t } [
    "y**" geekcode first second
    "z**" lookup-code second " Male." append =
] unit-test
{ t } [
    { "s++++:" "s:----" "s+:?:" "s++" "UZ++" "UL+++++"
      "y++***" "x++++++" "y?garbage" "y*+" "!y++" }
    [ dup geekcode-unknown first = ] all?
] unit-test


! Generic shape variables do not require a bare s rating in the table.
{ {
    { "Shape" "I have no knowledge of this category." }
    { "Shape" "I refuse to participate in this category." }
} } [ "s? !s" geekcode ] unit-test
{ { } } [ "s? !s" geekcode-unknown ] unit-test
{ t } [
    { "s++?" "!s++" "unknown?" "!unknown" }
    [ dup geekcode-unknown first = ] all?
] unit-test

! Public rows and their strings must not share mutable cache storage.
{ t } [
    "e++" geekcode first "changed" swap set-second
    "e++" geekcode first second "Got a Bachelors degree" =
] unit-test
{ t } [
    "e++" geekcode first first CHAR: X 0 rot set-nth
    "e++" geekcode first second CHAR: X 0 rot set-nth
    "e++" geekcode first { "Education" "Got a Bachelors degree" } =
] unit-test
{ t } [
    "e++ e++" geekcode dup first "changed" swap set-second
    second second "Got a Bachelors degree" =
] unit-test

! Decoding once for display preserves duplicate tokens and input order.
{ { "unknown" "unknown" } } [ "unknown e++ unknown" geekcode-unknown ] unit-test
{ t } [
    [ "e++ e++ unknown unknown" geekcode. ] with-string-writer
    "Education" split-subseq length 3 =
] unit-test
{ t } [
    [ "e++ e++ unknown unknown" geekcode. ] with-string-writer
    "Unrecognized codes: unknown unknown\n" tail?
] unit-test

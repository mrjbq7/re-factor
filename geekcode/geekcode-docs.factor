USING: help.markup help.syntax sequences strings ;
IN: geekcode

HELP: geekcode
{ $values { "str" string } { "rows" sequence } }
{ $description "Decodes supported Geek Code 3.12 tokens into an ordered sequence of category/description pairs. Returns independent, mutable rows and strings. Reads a bundled specification without accessing the network. Accepts plain strings and blocks labeled 3.1 or 3.12; unknown tokens are omitted. Use " { $link geekcode-unknown } " to inspect those tokens." }
{ $notes "Supports table ratings, slash-separated types, trailing @ and $, single parenthesized ranges, single goals, and generic ? and ! variables. Mixed shape ratings, Unix flavors, gender aliases, and combined sex ratings are also supported. Numeric ages, nested ranges, and repeated goals are not implemented." } ;

HELP: geekcode-unknown
{ $values { "str" string } { "tokens" sequence } }
{ $description "Returns unrecognized or unsupported tokens in input order. Supported block delimiters and version lines are excluded. A token with an unsupported component is returned whole. An unrecognized token may still be valid Geek Code." } ;

HELP: geekcode.
{ $values { "str" string } }
{ $description "Prints decoded Geek Code as a table and reports any unrecognized tokens below it." } ;

HELP: unsupported-geekcode-version
{ $values { "version" string } }
{ $description "Thrown when a block declares a version other than 3.1 or 3.12." } ;

ARTICLE: "geekcode" "Geek Code"
"The " { $vocab-link "geekcode" } " vocabulary decodes a subset of Robert A. Hayden's Geek Code 3.12 using a bundled specification."
{ $subsections geekcode geekcode-unknown geekcode. }
"Blocks declaring an unsupported version throw " { $link unsupported-geekcode-version } "." ;

ABOUT: "geekcode"

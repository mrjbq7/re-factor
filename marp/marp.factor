
USING: arrays combinators combinators.short-circuit formatting
help.markup help.topics html.streams io kernel sequences slides
splitting strings urls vocabs ;

<< "help.html" require >>

IN: marp

GENERIC: write-marp ( element -- )

M: string write-marp write ;

: write-slide ( children -- )
    "\n\n---\n\n# " write unclip print [
        dup { [ string? ] [ first string? ] } 1||
        [ "- " write ] when write-marp nl
    ] each ;

: write-code ( children -- )
    "```factor" print write-lines "```" print ;

: clean-link ( name -- name' )
    "[" "\\[" replace "]" "\\]" replace ;

: write-link ( children -- )
    first [ article-name clean-link ] [ >link url-of ] bi
    "[%s](https://docs.factorcode.org/content/%s)" printf ;

: write-url ( children -- )
    [ ?second clean-link ] [ first ] bi [ or ] keep >url
    "[%s](%s)" printf ;

: write-vocab-link ( children -- )
    first dup >vocab-link url-of
    "[%s](https://docs.factorcode.org/content/%s)" printf ;

: write-snippet ( children -- )
    "``" write [ write-marp ] each "``" write ;

M: array write-marp
    unclip {
        { \ $slide [ write-slide ] }
        { \ $code [ write-code ] }
        { \ $link [ write-link ] }
        { \ $vocab-link [ write-vocab-link ] }
        { \ $url [ write-url ] }
        { \ $snippet [ write-snippet ] }
        [ write-marp [ write-marp ] each ]
    } case ;

: write-marp-file ( slides -- )
    "---
marp: true
theme: gaia
paginate: true
backgroundColor: #1e1e2e
color: #cdd6f4
style: |
  section {
    font-family: 'SF Pro Display', 'Segoe UI', sans-serif;
  }
  h1 {
    color: #89b4fa;
  }
  h2 {
    color: #94e2d5;
  }
  h3 {
    color: #f5c2e7;
  }
  code {
    background-color: #313244;
    color: #cdd6f4;
    border-radius: 0.25em;
  }
  pre {
    background-color: #313244;
    border-radius: 0.5em;
  }
  ul {
    list-style: none;
    padding-left: 0;
  }
  ul li::before {
    content: \"▸ \";
    color: #89b4fa;
    font-weight: bold;
  }" print [ write-marp ] each ;

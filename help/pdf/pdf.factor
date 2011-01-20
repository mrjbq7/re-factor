! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs calendar colors combinators
combinators.smart destructors environment fonts formatting
hashtables io io.streams.string io.styles kernel locals make
math math.parser math.ranges memoize pdf sequences splitting
strings ;

IN: help.pdf

USE: pdf.values
USE: pdf.text


<PRIVATE

USE: io.encodings.utf8
USE: io.files

: foo-pdf ( pdf -- )
    "/Users/jbenedik/foo.pdf" utf8 set-file-contents ;

USE: fry
USE: help
USE: pdf.layout
USE: pdf.streams

: topics>pdf ( seq -- pdf )
    [ '[ _ print-topic ] with-pdf-writer ] map
    <pb> 1array join >pdf ;

PRIVATE>

: cookbook-pdf ( -- )
    {
        "cookbook-syntax"
        "cookbook-colon-defs"
        "cookbook-combinators"
        "cookbook-variables"
        "cookbook-vocabs"
        "cookbook-application"
        "cookbook-scripts"
        "cookbook-philosophy"
        "cookbook-pitfalls"
        "cookbook-next"
    } topics>pdf foo-pdf ;

: first-program-pdf ( -- )
    {
        "first-program-start"
        "first-program-logic"
        "first-program-test"
        "first-program-extend"
    } topics>pdf foo-pdf ;

: index-pdf ( -- )
    {
        "vocab-index"
        "article-index"
        "primitive-index"
        "error-index"
        "class-index"
    } topics>pdf foo-pdf ;

: handbook-pdf ( -- )
    {
        "handbook-language-reference"
        "conventions"
        "syntax"
        "evaluator"
        "effects"
        "inference"
        "booleans"
        "numbers"
        "collections"
        "words"
        "shuffle-words"
        "combinators"
        "threads"
        "locals"
        "namespaces"
        "namespaces-global"
        "values"
        "fry"
        "objects"
        "errors"
        "destructors"
        "memoize"
        "parsing-words"
        "macros"
        "continuations"
    } topics>pdf foo-pdf ;

: system-pdf ( -- )
    {
        "handbook-system-reference"
        "parser"
        "definitions"
        "vocabularies"
        "source-files"
        "compiler"
        "tools.errors"
        "images"
        "cli"
        "rc-files"
        "init"
        "system"
        "layouts"
    } topics>pdf foo-pdf ;

: tools-pdf ( -- )
    {
        "handbook-tools-reference"
        "listener"
        "editor"
        "vocabs.refresh"
        "tools.test"
        "help"
        "prettyprint"
        "inspector"
        "tools.inference"
        "tools.annotation"
        "tools.deprecation"
        "see"
        "tools.crossref"
        "vocabs.hierarchy"
        "timing"
        "profiling"
        "tools.memory"
        "tools.threads"
        "tools.destructors"
        "tools.diassemble"
        "tools.deploy"
    } topics>pdf foo-pdf ;


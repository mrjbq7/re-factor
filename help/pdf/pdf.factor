! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays help io.encodings.utf8 io.files io.pathnames
kernel pdf.layout pdf.streams sequences ;

IN: help.pdf

<PRIVATE

: topics>pdf ( seq -- pdf )
    [ [ print-topic ] curry with-pdf-writer ] map
    <pb> 1array join >pdf ;

: write-pdf ( seq name -- )
    home prepend-path utf8 set-file-contents ;

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
    } topics>pdf "cookbook.pdf" write-pdf ;

: first-program-pdf ( -- )
    {
        "first-program-start"
        "first-program-logic"
        "first-program-test"
        "first-program-extend"
    } topics>pdf "first-program.pdf" write-pdf ;

: index-pdf ( -- )
    {
        "vocab-index"
        "article-index"
        "primitive-index"
        "error-index"
        "class-index"
    } topics>pdf "index.pdf" write-pdf ;

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
    } topics>pdf "handbook.pdf" write-pdf ;

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
    } topics>pdf "system.pdf" write-pdf ;

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
    } topics>pdf "tools.pdf" write-pdf ;


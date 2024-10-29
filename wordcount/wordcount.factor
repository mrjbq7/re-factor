! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs combinators.short-circuit
formatting fry io io.directories io.encodings.ascii io.files
io.files.info kernel sequences sorting splitting ;

IN: wordcount

: \w? ( ch -- ? )
    { [ Letter? ] [ digit? ] [ CHAR: _ = ] } 1|| ; inline

: split-words ( seq -- seq' )
    [ \w? not ] split-when harvest ;

: count-words ( path -- assoc )
    f H{ } clone [
        '[
            dup regular-file? [
                name>> ascii file-contents >lower
                split-words [ _ inc-at ] each
            ] [ drop ] if
        ] each-directory-entry
    ] keep ;

: print-words ( alist -- )
    [ "%s\t%d\n" printf ] assoc-each ;

: write-count ( assoc -- )
    [
        "Writing counts in decreasing order" write nl
        [ "/tmp/counts-decreasing-factor" ascii ] dip
        '[ _ sort-values reverse print-words ] with-file-writer
    ] [
        "Writing counts in alphabetical order" write nl
        [ "/tmp/counts-alphabetical-factor" ascii ] dip
        '[ _ sort-keys print-words ] with-file-writer
    ] bi ;

! http://blogs.sourceallies.com/2009/12/word-counts-example-in-ruby-and-scala/
! http://www.bestinclass.dk/index.php/2009/12/clojure-vs-ruby-scala-transient-newsgroups/

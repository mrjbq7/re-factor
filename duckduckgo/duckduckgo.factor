! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs combinators http.client json.reader kernel
sequences urls ;

IN: duckduckgo

<PRIVATE

: search-url ( query -- url )
    URL" http://api.duckduckgo.com"
        swap "q" set-query-param
        "json" "format" set-query-param
        "1" "pretty" set-query-param
        "1" "no_redirect" set-query-param
        "1" "no_html" set-query-param
        "1" "skip_disambig" set-query-param ;

TUPLE: abstract html text url source heading ;
TUPLE: answer text type url ;
TUPLE: result html text url ;
TUPLE: redirect url ;
TUPLE: definition text url source ;
TUPLE: results type image answer result related-topics abstract
definition redirect ;

: >abstract ( json -- abstract )
    {
        [ "Abstract" swap at ]
        [ "AbstractText" swap at ]
        [ "AbstractURL" swap at ]
        [ "AbstractSource" swap at ]
        [ "Heading" swap at ]
    } cleave abstract boa ;

: >answer ( json -- answer )
    [ "Answer" swap at ]
    [ "AnswerType" swap at ] bi f answer boa ;

: >definition ( json -- definition )
    [ "Definition" swap at ]
    [ "DefinitionURL" swap at ]
    [ "DefinitionSource" swap at ] tri definition boa ;

: >redirect ( json -- redirect )
    "Redirect" swap at redirect boa ;

: >result ( json -- result )
    [ "Result" swap at ]
    [ "Text" swap at ]
    [ "FirstURL" swap at ] tri result boa ;

SYMBOLS: +article+ +disambiguation+ +category+ +name+
+exclusive+ +nothing+ ;

: >results ( json -- results )
    {
        [
            "Type" swap at H{
                { "A" +article+ }
                { "D" +disambiguation+ }
                { "C" +category+ }
                { "N" +name+ }
                { "E" +exclusive+ }
                { "" +nothing+ }
            } at
        ]
        [ "Image" swap at ]
        [ >answer ]
        [ "Results" swap at [ >result ] map ]
        [ "RelatedTopics" swap at [ >result ] map ]
        [ >abstract ]
        [ >definition ]
        [ >redirect ]
    } cleave results boa ;

PRIVATE>

: search ( query -- results )
    search-url http-get nip json> >results ;

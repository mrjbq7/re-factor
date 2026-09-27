USING: arrays ascii combinators kernel locals math sequences
splitting strings vectors ;
IN: shlex

ERROR: shlex-unclosed-quote quote ;
ERROR: shlex-missing-escape ;

<PRIVATE

: shlex-whitespace? ( ch -- ? ) " \t\r\n" member? ;

: shlex-quote? ( ch -- ? ) "'\"" member? ;

: emit-shlex-token ( token tokens -- )
    [ >string ] dip push ;

PRIVATE>

! Like Python's shlex.split(s, comments=False, posix=True).
:: shlex-split ( string comments? posix? -- tokens )
    V{ } clone :> tokens
    V{ } clone :> token!
    f :> started?!
    f :> quote!
    f :> escaped?!
    f :> comment?!
    string [| ch |
        {
            { [ comment? ] [
                ch CHAR: \n = [ f comment?! ] when
            ] }
            { [ escaped? ] [
                quote [
                    ch quote = ch CHAR: \\ = or
                    [ CHAR: \\ token push ] unless
                ] when
                ch token push
                f escaped?!
            ] }
            { [ quote ] [
                ch quote = [
                    posix? [
                        f quote!
                    ] [
                        ch token push
                        token tokens emit-shlex-token
                        V{ } clone token!
                        f started?!
                        f quote!
                    ] if
                ] [
                    posix? quote CHAR: " = and ch CHAR: \\ = and
                    [ t escaped?! ] [ ch token push ] if
                ] if
            ] }
            { [ comments? ch CHAR: # = and ] [
                t comment?!
                posix? started? and [
                    token tokens emit-shlex-token
                    V{ } clone token!
                    f started?!
                ] when
            ] }
            { [ ch shlex-whitespace? ] [
                started? [
                    token tokens emit-shlex-token
                    V{ } clone token!
                    f started?!
                ] when
            ] }
            { [ posix? ch CHAR: \\ = and ] [
                t started?! t escaped?!
            ] }
            { [ ch shlex-quote? posix? started? not or and ] [
                ch quote!
                t started?!
                posix? [ ch token push ] unless
            ] }
            [ ch token push t started?! ]
        } cond
    ] each
    escaped? [ shlex-missing-escape ] when
    quote [ quote shlex-unclosed-quote ] when
    started? [ token tokens emit-shlex-token ] when
    tokens >array ;

: parse-shlex ( string -- tokens ) f t shlex-split ;

<PRIVATE

: shlex-safe? ( ch -- ? )
    dup Letter? [ drop t ] [
        dup digit? [ drop t ] [ "_@%+=:,./-" member? ] if
    ] if ;

PRIVATE>

: shlex-quote ( string -- quoted )
    dup empty? [ drop "''" ] [
        dup [ shlex-safe? ] all? [
            "'" "'\"'\"'" replace "'" dup surround
        ] unless
    ] if ;

: shlex-join ( tokens -- string ) [ shlex-quote ] map " " join ;

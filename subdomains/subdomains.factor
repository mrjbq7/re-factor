! Copyright (C) 2024 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators.short-circuit dns http.download
io.encodings.utf8 io.files io.files.temp kernel math.order
sequences sorting splitting ;

IN: subdomains

MEMO: top-5000-subdomains ( -- subdomains )
    "https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Discovery/DNS/subdomains-top1million-5000.txt"
    cache-directory download-once-into utf8 file-lines ;

: remove-common-subdomains ( host -- host' )
    top-5000-subdomains [ "." append ] map '[ _ [ ?head ] any? ] loop ;

: remove-prefixed ( seq -- seq' )
    sort V{ } clone [
        dup '[
            [ _ [ head? ] with none? ] _ push-when
        ] each
    ] keep ;

: remove-observed-subdomains ( hosts -- hosts' )
    [ "." prepend reverse ] map remove-prefixed [ reverse rest ] map ;

: valid-domain? ( host -- ? )
    {
        [ dns-A-query message>a-names empty? not ]
        [ dns-AAAA-query message>aaaa-names empty? not ]
    } 1|| ;

: split-domain ( host -- hosts )
    "." split dup length 1 [-] <iota> [ tail "." join ] with map ;

: remove-subdomains ( host -- host' )
    split-domain [ valid-domain? ] find-last nip ;

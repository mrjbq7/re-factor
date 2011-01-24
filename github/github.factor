! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs combinators formatting http.client
json.reader kernel math sequences sorting utils ;

IN: github

CONSTANT: API-URL "http://github.com/api/v2/json"

<PRIVATE

TUPLE: user blog company created_at email followers_count
following_count gravatar_id id location login name permission
public_gist_count public_repo_count type ;

TUPLE: repository created_at description fork forks
has_downloads has_issues has_wiki homepage language name
open_issues organization owner private pushed_at size url
watchers ;

TUPLE: commit added author authored_date committed_date
committer id message modified parents tree url ;

: json-data ( url root -- data )
    [ API-URL prepend http-get nip json> ] [ swap at ] bi* ;

PRIVATE>

: user-info ( login -- user )
    "/user/show/%s" sprintf "user" json-data
    \ user from-slots ;

: following ( login -- seq )
    "/user/show/%s/following" sprintf "users" json-data ;

: followers ( login -- seq )
    "/user/show/%s/followers" sprintf "users" json-data ;

: repositories ( login -- seq )
    "/repos/show/%s" sprintf "repositories" json-data
    [ \ repository from-slots ] map ;

: watched ( login -- seq )
    "/repos/watched/%s" sprintf "repositories" json-data
    [ \ repository from-slots ] map ;

: repository ( login reponame -- repo )
    "/repos/show/%s/%s" sprintf "repository" json-data
    \ repository from-slots ;

: branches ( login reponame -- seq )
    "/repos/show/%s/%s/branches" sprintf "branches" json-data ;

: network ( login reponame -- seq )
    "/repos/show/%s/%s/network" sprintf "network" json-data
    [ \ repository from-slots ] map ;

: commits ( login reponame branch -- seq )
    "/commits/list/%s/%s/%s" sprintf "commits" json-data
    [ \ commit from-slots ] map ;

: commit ( login reponame commit-id -- commit )
    "/commits/show/%s/%s/%s" sprintf "commit" json-data
    \ commit from-slots ;

: vain ( login -- )
    [
        user-info {
            [ login>> ]
            [ followers_count>> ]
            [ public_repo_count>> ]
        } cleave
        "%s - %s followers - %s public repositories\n" printf
    ] [
        repositories [ watchers>> 1.0 swap / ] sort-with [
            {
                [ name>> ]
                [ watchers>> "%s watchers" sprintf ]
                [ forks>> "%s forks" sprintf ]
                [ fork>> "(FORK)" "" ? ]
            } cleave "%-25s %12s %12s %s\n" printf
        ] each
    ] bi ;


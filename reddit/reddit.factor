! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs calendar combinators formatting
http.client json.reader kernel math sequences utils ;

IN: reddit

<PRIVATE

TUPLE: comment author body body_html created created_utc downs
id levenshtein likes link_id link_title name parent_id replies
subreddit subreddit_id ups ;

TUPLE: user comment_karma created created_utc has_mail
has_mod_mail id is_mod link_karma name ;

TUPLE: story author clicked created created_utc domain downs
hidden id is_self levenshtein likes media media_embed name
num_comments over_18 permalink saved score selftext
selftext_html subreddit subreddit_id thumbnail title ups url ;

TUPLE: subreddit created created_utc description display_name id
name over18 subscribers title url ;

: parse-data ( assoc -- obj )
    [ "data" swap at ] [ "kind" swap at ] bi {
        { "t1" [ comment ] }
        { "t2" [ user ] }
        { "t3" [ story ] }
        { "t5" [ subreddit ] }
        [ throw ]
    } case from-slots ;

: json-data ( url -- data )
    http-get nip json> { "data" "children" } [ swap at ] each
    [ parse-data ] map ;

: (user) ( username -- data )
    "http://api.reddit.com/user/%s" sprintf json-data ;

: (about) ( username -- data )
    "http://api.reddit.com/user/%s/about" sprintf
    http-get nip json> parse-data ;

: (subreddit) ( subreddit -- data )
    "http://api.reddit.com/r/%s" sprintf json-data ;

: (url) ( url -- data )
    "http://api.reddit.com/api/info?url=%s" sprintf json-data ;

: (search) ( query -- data )
    "http://api.reddit.com/search?q=%s" sprintf json-data ;

: (subreddits) ( query -- data )
    "http://api.reddit.com/reddits/search?q=%s" sprintf json-data ;

PRIVATE>

: user-links ( username -- stories )
    (user) [ story? ] filter [ url>> ] map ;

: user-comments ( username -- comments )
    (user) [ comment? ] filter [ body>> ] map ;

: user-karma ( username -- karma )
    (about) link_karma>> ;

: url-score ( url -- score )
    (url) [ score>> ] map-sum ;

: subreddit-links ( subreddit -- links )
    (subreddit) [ url>> ] map ;

: subreddit-top ( subreddit -- )
    (subreddit) [
        1 + "%2d. " printf {
            [ title>> ]
            [ url>> ]
            [ score>> ]
            [ num_comments>> ]
            [
                created_utc>> unix-time>timestamp now swap time-
                duration>hours "%d hours ago" sprintf
            ]
            [ author>> ]
        } cleave
        "%s\n    %s\n    %d points, %d comments, posted %s by %s\n\n"
        printf
    ] each-index ;


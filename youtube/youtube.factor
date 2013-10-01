! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs http.client kernel make math.order sequences
splitting urls urls.encoding ;

IN: youtube

CONSTANT: video-info-url URL" http://www.youtube.com/get_video_info"

: get-video-info ( video-id -- video-info )
    video-info-url clone
        3 "asv" set-query-param
        "detailpage" "el" set-query-param
        "en_US" "hl" set-query-param
        swap "video_id" set-query-param
    http-get nip query>assoc ;

: video-formats ( video-info -- video-formats )
    "url_encoded_fmt_stream_map" of "," split
    [ query>assoc ] map ;

: video-download-url ( video-format -- url )
    [ "url" of ] [ "sig" of ] bi "&signature=" glue ;

: sanitize ( title -- title' )
    [ 0 31 between? not ] filter
    [ "\"#$%'*,./:;<>?^|~\\" member? not ] filter
    200 short head ;

: download-video ( video-id -- )
    get-video-info [
        video-formats [ "type" of "video/mp4" head? ] find nip
        video-download-url
    ] [
        "title" of sanitize ".mp4" append download-to
    ] bi ;


USING: accessors classes.tuple http.client io
io.encodings.binary io.files kernel make math.order sequences
splitting urls urls.encoding ;

IN: youtube

CONSTANT: video-info-url URL" http://www.youtube.com/get_video_info"

! YouTube quality and codecs id map.
! source: http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
CONSTANT: encoding H{

    ! Flash Video
    { 5 { "flv" "240p" "Sorenson H.263" "N/A" "0.25" "MP3" "64" } }
    { 6 { "flv" "270p" "Sorenson H.263" "N/A" "0.8" "MP3" "64" } }
    { 34 { "flv" "360p" "H.264" "Main" "0.5" "AAC" "128" } }
    { 35 { "flv" "480p" "H.264" "Main" "0.8-1" "AAC" "128" } }

    ! 3GP
    { 36 { "3gp" "240p" "MPEG-4 Visual" "Simple" "0.17" "AAC" "38" } }
    { 13 { "3gp" "N/A" "MPEG-4 Visual" "N/A" "0.5" "AAC" "N/A" } }
    { 17 { "3gp" "144p" "MPEG-4 Visual" "Simple" "0.05" "AAC" "24" } }

    ! MPEG-4
    { 18 { "mp4" "360p" "H.264" "Baseline" "0.5" "AAC" "96" } }
    { 22 { "mp4" "720p" "H.264" "High" "2-2.9" "AAC" "192" } }
    { 37 { "mp4" "1080p" "H.264" "High" "3-4.3" "AAC" "192" } }
    { 38 { "mp4" "3072p" "H.264" "High" "3.5-5" "AAC" "192" } }
    { 82 { "mp4" "360p" "H.264" "3D" "0.5" "AAC" "96" } }
    { 83 { "mp4" "240p" "H.264" "3D" "0.5" "AAC" "96" } }
    { 84 { "mp4" "720p" "H.264" "3D" "2-2.9" "AAC" "152" } }
    { 85 { "mp4" "520p" "H.264" "3D" "2-2.9" "AAC" "152" } }

    ! WebM
    { 43 { "webm" "360p" "VP8" "N/A" "0.5" "Vorbis" "128" } }
    { 44 { "webm" "480p" "VP8" "N/A" "1" "Vorbis" "128" } }
    { 45 { "webm" "720p" "VP8" "N/A" "2" "Vorbis" "192" } }
    { 46 { "webm" "1080p" "VP8" "N/A" "N/A" "Vorbis" "192" } }
    { 100 { "webm" "360p" "VP8" "3D" "N/A" "Vorbis" "128" } }
    { 101 { "webm" "360p" "VP8" "3D" "N/A" "Vorbis" "192" } }
    { 102 { "webm" "720p" "VP8" "3D" "N/A" "Vorbis" "192" } }
}

CONSTANT: encoding-keys {
    "extension" "resolution" "video_codec" "profile"
    "video_bitrate", "audio_codec" "audio_bitrate"
}

TUPLE: video-info abd account_playback_token ad3_module
ad_channel_code_instream ad_channel_code_overlay ad_device
ad_eurl ad_flags ad_host ad_host_tier ad_logging_flag ad_preroll
ad_slots ad_tag ad_video_pub_id adaptive_fmts
adsense_video_doc_id aftv afv afv_ad_tag
afv_ad_tag_restricted_to_instream afv_instream_max
afv_merge_enabled afv_video_min_cpm allow_embed allow_ratings
allowed_ads as_launched_in_country author avg_rating c
cafe_experiment_id cid content_owner_name dash dashmpd dclk
dynamic_allocation_ad_tag endscreen_module eventid fexp fmt_list
ftoken gut_tag has_cc host_language idpj iurl keywords ldpj
length_seconds loeid max_dynamic_allocation_ad_tag_length
midroll_freqcap mpu mpvid muted no_afv_instream no_get_video_log
oid plid pltype ptchn ptk pyv_in_related_cafe_experiment_id rvs
sendtmp sffb share_icons shortform status storyboard_spec
supported_without_ads sw tag_for_child_directed thumbnail_url
timestamp title tmi token track_embed trueview
url_encoded_fmt_stream_map use_cipher_signature video_id
video_verticals view_count vq watermark yt_pt ;

TUPLE: video-format fallback_host itag quality sig type url ;

: get-video-info ( video-id -- video-info )
    video-info-url clone
        3 "asv" set-query-param
        "detailpage" "el" set-query-param
        "en_US" "hl" set-query-param
        swap "video_id" set-query-param
    http-get nip query>assoc video-info from-slots ;

: video-formats ( video-info -- video-formats )
    url_encoded_fmt_stream_map>> "," split
    [ query>assoc video-format from-slots ] map ;

: video-download-url ( video-format -- url )
    [ url>> ] [ sig>> ] bi "&signature=" glue ;

: sanitize ( title -- title' )
    [ 0 31 between? not ] filter
    [ "\"#$%'*,./:;<>?^|~\\" member? not ] filter
    200 short head ;

: download-video ( video-id -- )
    get-video-info [
        video-formats [ type>> "video/mp4" head? ] find nip
        video-download-url
    ] [
        title>> sanitize ".mp4" append download-to
    ] bi ;

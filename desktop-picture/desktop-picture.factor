! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors html.parser.analyzer http.client http.download
io.files.temp kernel regexp sequences splitting strings system
vocabs ;

IN: desktop-picture

HOOK: get-desktop-picture os ( -- path )

HOOK: set-desktop-picture os ( path -- )

: random-imgur ( -- url )
    "https://imgur.com/random" scrape-html nip
    "image_src" "rel" find-by-attribute-key-value
    first "href" attribute ;

: random-xkcd ( -- url )
    "http://dynamic.xkcd.com/random/comic/" http-get nip
    R/ http:\/\/imgs\.xkcd\.com\/comics\/[^\.]+\.(png|jpg)/
    first-match >string ;

: random-wallpaperstock ( -- url )
    "http://wallpaperstock.net/random-wallpapers.html"
    scrape-html nip "wallpaper_thumb" find-by-class-between
    "a" find-by-name nip "href" attribute
    "http://wallpaperstock.net" prepend scrape-html nip
    "the_view_link" find-by-id nip "href" attribute
    "http:" prepend scrape-html nip "myImage" find-by-id nip
    "src" attribute "http:" prepend ;

: download-and-set-desktop-picture ( url -- )
    dup "/" split1-last nip cache-file
    [ download-into ] [ set-desktop-picture ] bi ;

"desktop-picture." os name>> append require
